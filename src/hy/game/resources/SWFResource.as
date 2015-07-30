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
		private var loader : Loader;
		private var appDomain : ApplicationDomain;

		public function SwfResource(res_url : String, version : String)
		{
			super(res_url, version);
		}

		override name_part function startLoad(context : LoaderContext = null) : void
		{
			if (isStartLoad || isLoaded || isDestroy)
			{
				warning(url, "isLoaded", isStartLoad, isLoaded, isDestroy);
				return;
			}
			super.startLoad(context);

			if (context == null)
			{
				context = new LoaderContext();
				context.applicationDomain = ApplicationDomain.currentDomain;
			}

			loader = new Loader();
			loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, onProgressEvent);
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onDownLoadComplete);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onDownloadError);
			loader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onDownloadSecurityError);
			reload();
		}

		override protected function reload() : void
		{
			try
			{
				loader.load(request, context);
			}
			catch (e : Error)
			{
			}
		}

		override protected function onDownLoadComplete(evt : Event) : void
		{
			if (loader && loader.contentLoaderInfo)
				appDomain = loader.contentLoaderInfo.applicationDomain;
			super.onDownLoadComplete(evt);
		}

		public function getAssetClass(name : String) : Class
		{
			if (appDomain == null)
				throw new Error("not initialized");

			if (appDomain.hasDefinition(name))
				return appDomain.getDefinition(name) as Class;
			else
				return null;
		}

		override public function stop() : void
		{
			try
			{
				if (loader)
				{
					loader.close();
					loader.unloadAndStop();
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
			if (loader)
			{
				if (loader.contentLoaderInfo)
				{
					loader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, onProgressEvent);
					loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onDownLoadComplete);
					loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onDownloadError);
					loader.contentLoaderInfo.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onDownloadSecurityError);
				}
			}
		}

		override protected function destroy() : void
		{
			super.destroy();
			appDomain = null;
			if (loader)
			{
				try
				{
					loader.unloadAndStop();
					loader = null;
				}
				catch (e : Error)
				{
				}
			}
		}
	}
}