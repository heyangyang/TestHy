package hy.game.resources
{
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	
	import hy.game.namespaces.name_part;
	use namespace name_part;

	/**
	 * 加载swf
	 * @author hyy
	 *
	 */
	public class SwfResource extends SResource
	{
		private var mLoader : Loader;
		private var mAppDomain : ApplicationDomain;

		public function SwfResource(res_url : String, version : String)
		{
			super(res_url, version);
		}

		override name_part function startLoad(context : LoaderContext = null) : void
		{
			if (isStartLoad || isLoaded || isDispose)
			{
				warning(url, "isLoaded", isStartLoad, isLoaded, isDispose);
				return;
			}
			super.startLoad(context);

			if (context == null)
			{
				context = new LoaderContext();
				context.applicationDomain = ApplicationDomain.currentDomain;
			}

			mLoader = new Loader();
			mLoader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, onProgressEvent);
			mLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onDownLoadComplete);
			mLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onDownloadError);
			mLoader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onDownloadSecurityError);
			reload();
		}

		override protected function reload() : void
		{
			try
			{
				mLoader.load(mRequest, mContext);
			}
			catch (e : Error)
			{
			}
		}

		override protected function onDownLoadComplete(evt : Event) : void
		{
			if (mLoader && mLoader.contentLoaderInfo)
				mAppDomain = mLoader.contentLoaderInfo.applicationDomain;
			super.onDownLoadComplete(evt);
		}

		public function getAssetClass(name : String) : Class
		{
			if (mAppDomain == null)
				throw new Error("not initialized");

			if (mAppDomain.hasDefinition(name))
				return mAppDomain.getDefinition(name) as Class;
			else
				return null;
		}

		override public function stop() : void
		{
			try
			{
				if (mLoader)
				{
					mLoader.close();
					mLoader.unloadAndStop();
				}
			}
			catch (e : Error)
			{
			}
			super.stop();
		}


		/**
		 * 清除监听
		 *
		 */
		override public function cleanListeners() : void
		{
			if (mLoader)
			{
				if (mLoader.contentLoaderInfo)
				{
					mLoader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, onProgressEvent);
					mLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onDownLoadComplete);
					mLoader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onDownloadError);
					mLoader.contentLoaderInfo.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onDownloadSecurityError);
				}
			}
		}

		override protected function dispose() : void
		{
			super.dispose();
			mAppDomain = null;
			if (mLoader)
			{
				try
				{
					mLoader.unloadAndStop();
					mLoader = null;
				}
				catch (e : Error)
				{
				}
			}
		}
	}
}