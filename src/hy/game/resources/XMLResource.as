package hy.game.resources
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.system.System;
	import flash.utils.ByteArray;
	
	import hy.game.namespaces.name_part;

	/**
	 * 加载xml
	 * @author hyy
	 *
	 */
	public class XMLResource extends SResource
	{
		public var xml : XML;
		private var loader : URLLoader;

		public function XMLResource(res_url : String, version : String)
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

		override protected function onDownLoadComplete(evt : Event) : void
		{
			var data : Object = ((evt.target) as URLLoader).data

			if (data is ByteArray)
				data = (data as ByteArray).readUTFBytes((data as ByteArray).length);

			try
			{
				xml = new XML(data);
				if (data is ByteArray)
					(data as ByteArray).clear();
			}
			catch (e : TypeError)
			{

			}
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
			if (xml)
			{
				System.disposeXML(xml);
				xml = null;
			}
			super.destroy();
			loader = null;
		}
	}
}