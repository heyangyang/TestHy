package hy.game.thread
{
	import flash.events.Event;
	import flash.system.MessageChannel;
	import flash.system.Worker;
	import flash.system.WorkerDomain;
	import flash.system.WorkerState;
	import flash.utils.ByteArray;
	
	import hy.game.cfg.Config;

	/**
	 * 主线程
	 *
	 */
	public class SMainThread
	{
		protected var mMainToBackChannel : MessageChannel;
		protected var mBackToMainChannel : MessageChannel;
		protected var mBackWorker : Worker;
		protected var mShareBytes : ByteArray;

		public function SMainThread()
		{
			super();
		}

		protected function initWorker(workerBytes : ByteArray) : void
		{
			mShareBytes = new ByteArray();
			mShareBytes.shareable = true;

			mBackWorker = WorkerDomain.current.createWorker(workerBytes);
			mMainToBackChannel = Worker.current.createMessageChannel(mBackWorker);
			mBackToMainChannel = mBackWorker.createMessageChannel(Worker.current);
			mBackWorker.setSharedProperty(SThreadType.BACK_TO_MAIN_THREAD, mBackToMainChannel);
			mBackWorker.setSharedProperty(SThreadType.MAIN_TO_BACK_THREAD, mMainToBackChannel);
			mBackWorker.setSharedProperty("supportDirectX", Config.supportDirectX);
			mBackWorker.setSharedProperty("share_bytes", mShareBytes);

			mBackToMainChannel.addEventListener(Event.CHANNEL_MESSAGE, onBackToMain, false, 0, true);
			mBackWorker.addEventListener(Event.WORKER_STATE, handleBGWorkerStateChange);
			mBackWorker.start();
		}

		private function handleBGWorkerStateChange(evt : Event) : void
		{
			if (mBackWorker.state == WorkerState.TERMINATED)
			{
			}
		}

		protected function onBackToMain(event : Event) : void
		{
			if (!mBackToMainChannel.messageAvailable)
				return;
			var message : * = mBackToMainChannel.receive(true);
		}
	}
}