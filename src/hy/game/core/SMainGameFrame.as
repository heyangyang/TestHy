package hy.game.core
{
	import flash.display.Stage;
	import flash.events.Event;
	import flash.utils.getTimer;
	
	import hy.game.interfaces.core.IEnterFrame;


	public class SMainGameFrame
	{
		private static var instance : SMainGameFrame;

		public static function getInstance() : SMainGameFrame
		{
			if (instance == null)
				instance = new SMainGameFrame();
			return instance;
		}

		private var mFrames : Vector.<IEnterFrame>;
		private var mCurFrame : IEnterFrame;
		private var mElapsedTime : int;

		public function SMainGameFrame()
		{

		}

		public function init(stage : Stage) : void
		{
			mElapsedTime = getTimer();
			mFrames = new Vector.<IEnterFrame>();
			stage.addEventListener(Event.ENTER_FRAME, onEnterFrame, false, 999);
		}

		public function addGameFrame(frame : IEnterFrame) : void
		{
			if (mFrames.indexOf(frame) == -1)
				mFrames.push(frame);
		}

		private function onEnterFrame(evt : Event) : void
		{
			STime.getTimer = getTimer();
			STime.deltaTime = STime.getTimer - mElapsedTime;
			mElapsedTime = STime.getTimer;
			for each (mCurFrame in mFrames)
			{
				mCurFrame.update();
			}
			STime.passedTime = getTimer() - STime.getTimer;
		}
	}
}