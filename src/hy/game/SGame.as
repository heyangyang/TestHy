package hy.game

{
	import flash.display.Stage;
	
	import hy.game.core.SCamera;
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
			this.current_stage = current_stage;
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


	}
}