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
		private var mLoader : Loader;
		private var mBitmapData : BitmapData = null;

		public function ImageResource(res_url : String, version : String)
		{
			super(res_url, version);
		}

		override public function get data():*
		{
			if (mBitmapData != null)
				return new Bitmap(mBitmapData);
			warning("加载器没有图片: " + url);
			return null;
		}

		override name_part function startLoad(context : LoaderContext = null) : void
		{
			if (isLoading || isLoaded || isDispose)
				return;
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

			try
			{
				mLoader.load(mRequest, context);
			}
			catch (e : Error)
			{
			}
		}

		override protected function onDownLoadComplete(evt : Event) : void
		{
			if (evt.target.content is BitmapData)
			{
				mBitmapData = evt.target.content as BitmapData;
			}
			else if (evt.target.content is Bitmap)
			{
				mBitmapData = Bitmap(evt.target.content).bitmapData;
			}
			super.onDownLoadComplete(evt);
		}

		override public function cleanListeners() : void
		{
			if (mLoader)
			{
				mLoader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, onProgressEvent);
				mLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onDownLoadComplete);
				mLoader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onDownloadError);
				mLoader.contentLoaderInfo.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onDownloadSecurityError);
			}
		}

		override public function stop() : void
		{
			try
			{
				if (mLoader)
				{
					mLoader.close();
				}
			}
			catch (e : Error)
			{
			}
			super.stop();
		}

		override protected function dispose() : void
		{
			if (mLoader)
			{
				mLoader.unloadAndStop();
				stop();
				mLoader = null;
			}
			mBitmapData && mBitmapData.dispose();
			mBitmapData = null;
			super.dispose();
		}
	}
}