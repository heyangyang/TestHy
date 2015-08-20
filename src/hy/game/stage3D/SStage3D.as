package hy.game.stage3D
{
	import flash.display.Stage;
	import flash.display.Stage3D;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DCompareMode;
	import flash.display3D.Context3DRenderMode;
	import flash.display3D.Context3DTriangleFace;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.system.Capabilities;
	import flash.utils.setTimeout;

	import hy.game.core.SMainGameFrame;
	import hy.game.core.event.SEvent;
	import hy.game.core.event.SEventDispatcher;
	import hy.game.core.interfaces.IEnterFrame;
	import hy.game.namespaces.name_part;
	import hy.game.stage3D.display.SDisplayObjectContainer;
	import hy.game.stage3D.utils.SystemUtil;

	use namespace name_part;

	public class SStage3D extends SEventDispatcher implements IEnterFrame
	{
		public static var handleLostContext : Boolean;
		public static var multitouchEnabled : Boolean;
		private static var sCurrent : SStage3D;

		public static function get current() : SStage3D
		{
			return sCurrent;
		}

		public static function get context() : Context3D
		{
			return sCurrent.context;
		}

		public static function get stage() : SDisplayObjectContainer
		{
			return sCurrent.mContainer;
		}

		private var mStage3D : Stage3D;
		private var mStage : Stage;
		private var mContainer : SDisplayObjectContainer;
		private var mProfile : String;
		private var mStageWidth : int;
		private var mStageHeight : int;
		private var mContext : Context3D;
		private var mAntiAliasing : int;
		private var mEnableErrorChecking : Boolean;
		private var mSupportHighResolutions : Boolean;
		private var mStarted : Boolean;
		private var mViewPort : Rectangle;
		private var mPreviousViewPort : Rectangle;

		public function SStage3D(stage : Stage, renderMode : String = "auto", profile : Object = "baselineConstrained")
		{
			viewPort = new Rectangle(0, 0, stage.stageWidth, stage.stageHeight);
			mStage = stage;
			mStage3D = stage.stage3Ds[0];
			mContainer = new SDisplayObjectContainer();
			mStageWidth = mViewPort.width;
			mStageHeight = mViewPort.height;
			mPreviousViewPort = new Rectangle();
			sCurrent = this;
			mStage3D.addEventListener(Event.CONTEXT3D_CREATE, onContextCreated, false, 10, true);
			mStage3D.addEventListener(ErrorEvent.ERROR, onStage3DError, false, 10, true);

			if (mStage3D.context3D && mStage3D.context3D.driverInfo != "Disposed")
			{
				if (profile == "auto" || profile is Array)
					throw new ArgumentError("When sharing the context3D, " + "the actual profile has to be supplied");
				else
					mProfile = "profile" in mStage3D.context3D ? mStage3D.context3D["profile"] : profile as String;

				setTimeout(initialize, 1); // we don't call it right away, because Starling should
					// behave the same way with or without a shared context
			}
			else
			{
				if (!SystemUtil.supportsDepthAndStencil)
					trace("[Starling] Mask support requires 'depthAndStencil' to be enabled" + " in the application descriptor.");

				requestContext3D(renderMode, profile);
			}
		}

		private function requestContext3D(renderMode : String, profile : Object) : void
		{
			var profiles : Array;
			var currentProfile : String;

			if (profile == "auto")
				profiles = ["standardExtended", "standard", "standardConstrained", "baselineExtended", "baseline", "baselineConstrained"];
			else if (profile is String)
				profiles = [profile as String];
			else if (profile is Array)
				profiles = profile as Array;
			else
				throw new ArgumentError("Profile must be of type 'String' or 'Array'");

			mStage3D.addEventListener(Event.CONTEXT3D_CREATE, onCreated, false, 100);
			mStage3D.addEventListener(ErrorEvent.ERROR, onError, false, 100);

			requestNextProfile();

			function requestNextProfile() : void
			{
				currentProfile = profiles.shift();

				try
				{
					mStage3D.requestContext3D(renderMode, currentProfile)
				}
				catch (error : Error)
				{
					if (profiles.length != 0)
						setTimeout(requestNextProfile, 1);
					else
						throw error;
				}
			}

			function onCreated(event : Event) : void
			{
				var context : Context3D = mStage3D.context3D;

				if (renderMode == Context3DRenderMode.AUTO && profiles.length != 0 && context.driverInfo.indexOf("Software") != -1)
				{
					onError(event);
				}
				else
				{
					mProfile = currentProfile;
					onFinished();
				}
			}

			function onError(event : Event) : void
			{
				if (profiles.length != 0)
				{
					event.stopImmediatePropagation();
					setTimeout(requestNextProfile, 1);
				}
				else
					onFinished();
			}

			function onFinished() : void
			{
				mStage3D.removeEventListener(Event.CONTEXT3D_CREATE, onCreated);
				mStage3D.removeEventListener(ErrorEvent.ERROR, onError);
			}
		}

		private function onContextCreated(event : Event) : void
		{
			if (!handleLostContext && mContext)
			{
				event.stopImmediatePropagation();
				trace("[Stage3D] Enable 'handleLostContext' to avoid this error.");
			}
			else
			{
				initialize();
			}
		}

		private function initialize() : void
		{
			mContext = mStage3D.context3D;
			mContext.enableErrorChecking = mEnableErrorChecking;
			SRenderSupport.sContext = mContext;
			dispatchEventWith(SEvent.ROOT_CREATED);
			SMainGameFrame.getInstance().addGameFrame(this);
		}

		public function start() : void
		{
			mStarted = true;
		}

		public function stop() : void
		{
			mStarted = false;
		}

		public function update() : void
		{
			mStarted && render();
		}

		public function render() : void
		{
			if (!contextValid)
				return;

			updateViewPort();
			SRenderSupport.reset();
			mContext.setDepthTest(false, Context3DCompareMode.ALWAYS);
			mContext.setCulling(Context3DTriangleFace.NONE);
			mContext.clear(0, 0, 0);
			mContainer.render();
			mContext.present();
		}


		private function updateViewPort(forceUpdate : Boolean = false) : void
		{
			if (forceUpdate || mPreviousViewPort.width != mViewPort.width || mPreviousViewPort.height != mViewPort.height || mPreviousViewPort.x != mViewPort.x || mPreviousViewPort.y != mViewPort.y)
			{
				mPreviousViewPort.setTo(mViewPort.x, mViewPort.y, mViewPort.width, mViewPort.height);

				if (mProfile == "baselineConstrained")
					configureBackBuffer(32, 32, mAntiAliasing, true);

				mStage3D.x = mViewPort.x;
				mStage3D.y = mViewPort.y;

				configureBackBuffer(mViewPort.width, mViewPort.height, mAntiAliasing, true, mSupportHighResolutions);
			}
		}

		private function configureBackBuffer(width : int, height : int, antiAlias : int, enableDepthAndStencil : Boolean, wantsBestResolution : Boolean = false) : void
		{
			enableDepthAndStencil &&= SystemUtil.supportsDepthAndStencil;

			var configureBackBuffer : Function = mContext.configureBackBuffer;
			var methodArgs : Array = [width, height, antiAlias, enableDepthAndStencil];
			if (configureBackBuffer.length > 4)
				methodArgs.push(wantsBestResolution);
			configureBackBuffer.apply(mContext, methodArgs);
		}

		public function get stageWidth() : int
		{
			return mStageWidth;
		}

		public function get stageHeight() : int
		{
			return mStageHeight;
		}

		public function get profile() : String
		{
			return mProfile;
		}

		public function get context() : Context3D
		{
			return mContext;
		}

		public function get antiAliasing() : int
		{
			return mAntiAliasing;
		}

		public function set antiAliasing(value : int) : void
		{
			if (mAntiAliasing != value)
			{
				mAntiAliasing = value;
				if (contextValid)
					updateViewPort(true);
			}
		}

		public function get enableErrorChecking() : Boolean
		{
			return mEnableErrorChecking;
		}

		public function set enableErrorChecking(value : Boolean) : void
		{
			mEnableErrorChecking = value;
			if (mContext)
				mContext.enableErrorChecking = value;
		}

		private function onStage3DError(event : ErrorEvent) : void
		{
			if (event.errorID == 3702)
			{
				var mode : String = Capabilities.playerType == "Desktop" ? "renderMode" : "wmode";
				trace("Context3D not available! Possible reasons: wrong " + mode + " or missing device support.");
			}
			else
				trace("Stage3D error: " + event.text);
		}

		public function get contextValid() : Boolean
		{
			return mContext && mContext.driverInfo != "Disposed";
		}

		public function get supportHighResolutions() : Boolean
		{
			return mSupportHighResolutions;
		}

		public function set supportHighResolutions(value : Boolean) : void
		{
			if (mSupportHighResolutions != value)
			{
				mSupportHighResolutions = value;
				if (contextValid)
					updateViewPort(true);
			}
		}

		public function get viewPort() : Rectangle
		{
			return mViewPort;
		}

		public function set viewPort(value : Rectangle) : void
		{
			mViewPort = value.clone();
			SRenderSupport.setProjectionMatrix(mViewPort.x, mViewPort.y, mViewPort.width, mViewPort.height, mViewPort.width, mViewPort.height);
		}

	}
}