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
	import flash.utils.ByteArray;

	import hy.game.namespaces.name_part;

	/**
	 * 加载文本
	 * 以2进制进行加载。
	 * 可以加载文本和2进制文件
	 * @author hyy
	 *
	 */
	public class TEXTResource extends SResource
	{
		public var loader : URLLoader;
		public var byteArray : ByteArray;

		public function TEXTResource(res_url : String, version : String)
		{
			super(res_url, version);
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
			}
		}

		public function get data() : String
		{
			if (byteArray == null)
				return "";
			return byteArray.toString();
		}

		override protected function onDownLoadComplete(evt : Event) : void
		{
			var data : Object = ((evt.target) as URLLoader).data

			if (data is ByteArray)
				this.byteArray = data as ByteArray;
			super.onDownLoadComplete(evt);
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
			if (byteArray)
			{
				byteArray.clear();
				this.byteArray = null;
			}
		}
	}
}