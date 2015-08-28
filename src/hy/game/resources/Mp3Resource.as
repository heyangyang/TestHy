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
		private var mSound : Sound;

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

			mSound = new Sound();
			mSound.addEventListener(ProgressEvent.PROGRESS, onProgressEvent);
			mSound.addEventListener(Event.COMPLETE, onDownLoadComplete);
			mSound.addEventListener(IOErrorEvent.IO_ERROR, onDownloadError);
			mSound.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onDownloadSecurityError);
			try
			{
				mSound.load(mRequest);
			}
			catch (e : Error)
			{

			}
		}

		override public function get data():*
		{
			return mSound;
		}
		
		override public function stop() : void
		{
			try
			{
				mSound && mSound.close();
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
			if (!mSound)
				return;
			mSound.removeEventListener(ProgressEvent.PROGRESS, onProgressEvent);
			mSound.removeEventListener(Event.COMPLETE, onDownLoadComplete);
			mSound.removeEventListener(IOErrorEvent.IO_ERROR, onDownloadError);
			mSound.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onDownloadSecurityError);
		}

		override protected function dispose() : void
		{
			super.dispose();
			this.mSound = null;
		}

	}
}