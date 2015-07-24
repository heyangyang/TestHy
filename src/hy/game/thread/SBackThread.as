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
		protected var worker : Worker;
		protected var mainToBackChannel : MessageChannel;
		protected var backToMainChannel : MessageChannel;

		public function SBackThread()
		{
			initWorker();
		}

		protected function initWorker() : void
		{
			worker = Worker.current;
			worker.addEventListener(Event.WORKER_STATE, handleBGWorkerStateChange);
			mainToBackChannel = worker.getSharedProperty(SThreadType.MAIN_TO_BACK_THREAD);
			backToMainChannel = worker.getSharedProperty(SThreadType.BACK_TO_MAIN_THREAD);
			Config.supportDirectX = worker.getSharedProperty("supportDirectX");
			if (mainToBackChannel)
			{
				mainToBackChannel.addEventListener(Event.CHANNEL_MESSAGE, onMainToBack);
			}
		}

		private function handleBGWorkerStateChange(evt : Event) : void
		{
			if (worker.state == WorkerState.TERMINATED)
			{
				throw new Error("主线程挂掉!");
			}
		}

		protected function onMainToBack(event : Event) : void
		{
			if (!mainToBackChannel.messageAvailable)
				return;
			var data : * = mainToBackChannel.receive(true);
		}
	}
}