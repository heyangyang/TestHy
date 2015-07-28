package hy.game

{
	import flash.display.Stage;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;

	import hy.game.cfg.Config;
	import hy.game.manager.SLayerManager;
	import hy.game.manager.SReferenceManager;
	import hy.game.net.SGameSocket;
	import hy.game.resources.SPreLoad;
	import hy.game.resources.SResourceMagnger;
	import hy.game.sound.SoundManager;
	import hy.game.utils.SDebug;
	import hy.game.utils.STimeControl;
	import hy.rpg.manager.SGameManager;

	public class SGame
	{
		private static var m_current : SGame;

		public static function get current() : SGame
		{
			return m_current
		}

		public function SGame(stage : Stage)
		{
			init(stage);
		}

		private var current_stage : Stage;

		private function init(stage : Stage) : void
		{
			if (m_current)
				SDebug.error("m_current != null");
			this.current_stage = stage;

			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.frameRate = Config.frameRate;
			stage.color = 0x000000;
			stage.addEventListener(Event.RESIZE, onResizeHandler);
			onResizeHandler(null);
			m_current = this;
			SDebug.init(stage);
			SLayerManager.getInstance().init(stage);
			SReferenceManager.getInstance();
			SPreLoad.getInstance();
			SResourceMagnger.getInstance();
			SGameSocket.getInstance();
			SoundManager.getInstance();
			STimeControl.getInstance();
			SGameManager.getInstance();
		}

		protected function onResizeHandler(event : Event) : void
		{
			Config.screenWidth = current_stage.stageWidth;
			Config.screenHeight = current_stage.stageHeight;
		}

	}
}