package hy.game.resources
{
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
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
		private var loader : URLLoader;
		private var m_data : *;

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

			loader = new URLLoader();
			loader.dataFormat = URLLoaderDataFormat.BINARY;
			loader.addEventListener(ProgressEvent.PROGRESS, onProgressEvent);
			loader.addEventListener(Event.COMPLETE, onDownLoadComplete);
			loader.addEventListener(IOErrorEvent.IO_ERROR, onDownloadError);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onDownloadSecurityError);

			try
			{
				loader.load(request);
			}
			catch (e : Error)
			{
				onDownloadError(null);
			}
		}

		override public function get data() : *
		{
			return m_data;
		}

		override protected function onDownLoadComplete(evt : Event) : void
		{
			m_data = ((evt.target) as URLLoader).data
			super.onDownLoadComplete(evt);
		}

		/**
		 * 清除监听
		 *
		 */
		override public function cleanListeners() : void
		{
			if (!loader)
				return;
			loader.removeEventListener(ProgressEvent.PROGRESS, onProgressEvent);
			loader.removeEventListener(Event.COMPLETE, onDownLoadComplete);
			loader.removeEventListener(IOErrorEvent.IO_ERROR, onDownloadError);
			loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onDownloadSecurityError);
		}

		override public function stop() : void
		{
			try
			{
				loader && loader.close();
			}
			catch (e : Error)
			{
			}
			super.stop();
		}

		override protected function destroy() : void
		{
			super.destroy();
			loader = null;
			m_data = null;
		}
	}
}