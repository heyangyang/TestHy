package hy.game.resources
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	
	import hy.game.namespaces.name_part;

	/**
	 * 加载图片
	 * @author hyy
	 *
	 */
	public class ImageResource extends SResource
	{
		private var loader : Loader;
		private var bitmapData : BitmapData = null;

		public function ImageResource(res_url : String, version : String)
		{
			super(res_url, version);
		}

		override public function get data():*
		{
			if (bitmapData != null)
				return new Bitmap(bitmapData);
			warning("加载器没有图片: " + url);
			return null;
		}

		override name_part function startLoad(context : LoaderContext = null) : void
		{
			if (isLoading || isLoaded || isDestroy)
				return;
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
			if (evt.target.content is BitmapData)
			{
				bitmapData = evt.target.content as BitmapData;
			}
			else if (evt.target.content is Bitmap)
			{
				bitmapData = Bitmap(evt.target.content).bitmapData;
			}
			super.onDownLoadComplete(evt);
		}

		override public function cleanListeners() : void
		{
			if (loader)
			{
				loader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, onProgressEvent);
				loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onDownLoadComplete);
				loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onDownloadError);
				loader.contentLoaderInfo.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onDownloadSecurityError);
			}
		}

		override public function stop() : void
		{
			try
			{
				if (loader)
				{
					loader.close();
				}
			}
			catch (e : Error)
			{
			}
			super.stop();
		}

		override protected function destroy() : void
		{
			if (loader)
			{
				loader.unloadAndStop();
				stop();
				loader = null;
			}
			bitmapData && bitmapData.dispose();
			bitmapData = null;
			super.destroy();
		}
	}
}