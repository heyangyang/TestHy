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
		protected var mainToBackChannel : MessageChannel;
		protected var backToMainChannel : MessageChannel;
		protected var backWorker : Worker;
		protected var share_bytes : ByteArray;

		public function SMainThread()
		{
			super();
		}

		protected function initWorker(workerBytes : ByteArray) : void
		{
			share_bytes = new ByteArray();
			share_bytes.shareable = true;

			backWorker = WorkerDomain.current.createWorker(workerBytes);
			mainToBackChannel = Worker.current.createMessageChannel(backWorker);
			backToMainChannel = backWorker.createMessageChannel(Worker.current);
			backWorker.setSharedProperty(SThreadType.BACK_TO_MAIN_THREAD, backToMainChannel);
			backWorker.setSharedProperty(SThreadType.MAIN_TO_BACK_THREAD, mainToBackChannel);
			backWorker.setSharedProperty("supportDirectX", Config.supportDirectX);
			backWorker.setSharedProperty("share_bytes", share_bytes);

			backToMainChannel.addEventListener(Event.CHANNEL_MESSAGE, onBackToMain, false, 0, true);
			backWorker.addEventListener(Event.WORKER_STATE, handleBGWorkerStateChange);
			backWorker.start();
		}

		private function handleBGWorkerStateChange(evt : Event) : void
		{
			if (backWorker.state == WorkerState.TERMINATED)
			{
			}
		}

		protected function onBackToMain(event : Event) : void
		{
			if (!backToMainChannel.messageAvailable)
				return;
			var message : * = backToMainChannel.receive(true);
		}
	}
}