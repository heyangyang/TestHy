package hy.game.resources
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	
	import hy.game.namespaces.name_part;

	use namespace name_part;

	/**
	 * 加载文本
	 * 以2进制进行加载。
	 * 可以加载文本和2进制文件
	 * @author hyy
	 *
	 */
	public class BytesResource extends SResource
	{
		private var mLoader : URLLoader;
		private var mData : *;

		public function BytesResource(res_url : String, version : String)
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

			mLoader = new URLLoader();
			mLoader.dataFormat = URLLoaderDataFormat.BINARY;
			mLoader.addEventListener(ProgressEvent.PROGRESS, onProgressEvent);
			mLoader.addEventListener(Event.COMPLETE, onDownLoadComplete);
			mLoader.addEventListener(IOErrorEvent.IO_ERROR, onDownloadError);
			mLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onDownloadSecurityError);

			try
			{
				mLoader.load(mRequest);
			}
			catch (e : Error)
			{
				onDownloadError(null);
			}
		}

		override public function get data() : *
		{
			return mData;
		}

		override protected function onDownLoadComplete(evt : Event) : void
		{
			mData = ((evt.target) as URLLoader).data
			super.onDownLoadComplete(evt);
		}

		/**
		 * 清除监听
		 *
		 */
		override public function cleanListeners() : void
		{
			if (!mLoader)
				return;
			mLoader.removeEventListener(ProgressEvent.PROGRESS, onProgressEvent);
			mLoader.removeEventListener(Event.COMPLETE, onDownLoadComplete);
			mLoader.removeEventListener(IOErrorEvent.IO_ERROR, onDownloadError);
			mLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onDownloadSecurityError);
		}

		override public function stop() : void
		{
			try
			{
				mLoader && mLoader.close();
			}
			catch (e : Error)
			{
			}
			super.stop();
		}

		override protected function dispose() : void
		{
			super.dispose();
			mLoader = null;
			mData = null;
		}
	}
}