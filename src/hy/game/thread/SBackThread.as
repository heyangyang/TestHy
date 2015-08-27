package hy.game.thread
{
	import flash.events.Event;
	import flash.system.MessageChannel;
	import flash.system.Worker;
	import flash.system.WorkerState;
	
	import hy.game.cfg.Config;

	/**
	 *
	 * 后台线程
	 *
	 */
	public class SBackThread
	{
		public static const BACK_TO_MAIN_THREAD : String = "backToMainThread";
		protected var mWorker : Worker;
		protected var mMainToBackChannel : MessageChannel;
		protected var mBackToMainChannel : MessageChannel;

		public function SBackThread()
		{
			initWorker();
		}

		protected function initWorker() : void
		{
			mWorker = Worker.current;
			mWorker.addEventListener(Event.WORKER_STATE, handleBGWorkerStateChange);
			mMainToBackChannel = mWorker.getSharedProperty(SThreadType.MAIN_TO_BACK_THREAD);
			mBackToMainChannel = mWorker.getSharedProperty(SThreadType.BACK_TO_MAIN_THREAD);
			Config.supportDirectX = mWorker.getSharedProperty("supportDirectX");
			if (mMainToBackChannel)
			{
				mMainToBackChannel.addEventListener(Event.CHANNEL_MESSAGE, onMainToBack);
			}
		}

		private function handleBGWorkerStateChange(evt : Event) : void
		{
			if (mWorker.state == WorkerState.TERMINATED)
			{
				throw new Error("主线程挂掉!");
			}
		}

		protected function onMainToBack(event : Event) : void
		{
			if (!mMainToBackChannel.messageAvailable)
				return;
			var data : * = mMainToBackChannel.receive(true);
		}
	}
}