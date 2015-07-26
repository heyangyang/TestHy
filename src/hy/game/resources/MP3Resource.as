package hy.game.resources
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.media.Sound;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	
	import hy.game.namespaces.name_part;

	[EditorData(extensions="mp3")]

	/**
	 * 加载声音
	 * @author hyy
	 *
	 */
	public class Mp3Resource extends SResource
	{
		private var sound : Sound;

		public function Mp3Resource(res_url : String, version : String)
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

			sound = new Sound();
			sound.addEventListener(ProgressEvent.PROGRESS, onProgressEvent);
			sound.addEventListener(Event.COMPLETE, onDownLoadComplete);
			sound.addEventListener(IOErrorEvent.IO_ERROR, onDownloadError);
			sound.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onDownloadSecurityError);
			try
			{
				sound.load(request);
			}
			catch (e : Error)
			{

			}
		}

		override public function get data():*
		{
			return sound;
		}
		
		override public function stop() : void
		{
			try
			{
				sound && sound.close();
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
			if (!sound)
				return;
			sound.removeEventListener(ProgressEvent.PROGRESS, onProgressEvent);
			sound.removeEventListener(Event.COMPLETE, onDownLoadComplete);
			sound.removeEventListener(IOErrorEvent.IO_ERROR, onDownloadError);
			sound.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onDownloadSecurityError);
		}

		override protected function destroy() : void
		{
			super.destroy();
			this.sound = null;
		}

	}
}