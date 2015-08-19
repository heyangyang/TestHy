package hy.game.stage3D
{
	import flash.display.Stage;
	import flash.display.Stage3D;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DRenderMode;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.utils.setTimeout;

	import starling.core.Starling;
	import starling.utils.SystemUtil;
	import starling.utils.execute;

	public class SStage3D
	{
		public static var handleLostContext : Boolean;
		private static var sCurrent : SStage3D;

		public static function get current() : SStage3D
		{
			return sCurrent;
		}
		private var mStage3D : Stage3D;
		private var mProfile : String;
		private var mStageWidth : int;
		private var mStageHeight : int;
		private var mContext : Context3D;

		public function SStage3D(rootClass : Class, stage : Stage, viewPort : Rectangle = null, stage3D : Stage3D = null, renderMode : String = "auto", profile : Object = "baselineConstrained")
		{
			if (viewPort == null)
				viewPort = new Rectangle(0, 0, stage.stageWidth, stage.stageHeight);
			if (stage3D == null)
				stage3D = stage.stage3Ds[0];
			mStage3D = stage3D;
			mStageWidth = viewPort.width;
			mStageHeight = viewPort.height;
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
					execute(mStage3D.requestContext3D, renderMode, currentProfile);
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
			if (!Starling.handleLostContext && mContext)
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
			mContext.enableErrorChecking = false;
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


	}
}