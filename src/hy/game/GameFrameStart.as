package hy.game

{
	import flash.display.Stage;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import hy.game.cfg.Config;
	import hy.game.core.GameDispatcher;
	import hy.game.manager.SKeyboardManager;
	import hy.game.manager.SLayerManager;
	import hy.game.update.SMouseUpdateMangaer;
	import hy.game.manager.SReferenceManager;
	import hy.game.manager.SUpdateManager;
	import hy.game.net.SGameSocket;
	import hy.game.resources.SPreLoad;
	import hy.game.resources.SResourceMagnger;
	import hy.game.sound.SoundManager;
	import hy.game.starter.SGameStartBase;
	import hy.game.utils.SDebug;
	import hy.game.utils.STimeControl;
	import hy.rpg.manager.ManagerGameCreate;

	/**
	 * 游戏运行入口
	 * @author wait
	 *
	 */
	public class GameFrameStart
	{
		private static var m_current : GameFrameStart;

		public static function get current() : GameFrameStart
		{
			return m_current
		}

		public function GameFrameStart(stage : Stage, sarter : SGameStartBase)
		{
			gameStarter = sarter;
			init(stage);
			sarter.onStart();
		}

		private var current_stage : Stage;
		private var gameStarter : SGameStartBase;

		private function init(stage : Stage) : void
		{
			if (m_current)
				SDebug.error("m_current != null");
			this.current_stage = stage;

			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.frameRate = Config.frameRate;
			stage.color = 0x000000;
			GameDispatcher.getInstance();
			stage.addEventListener(Event.RESIZE, onResizeHandler);
			stage.addEventListener(MouseEvent.RIGHT_CLICK, onRightClickHandler);
			onResizeHandler(null);
			Config.stage = stage;
			stage.focus = stage;
			m_current = this;
			SDebug.init(stage);
			SMouseUpdateMangaer.getInstance().init(stage);
			SLayerManager.getInstance().init(stage);
			SUpdateManager.getInstance().init(stage);
			SKeyboardManager.getInstance().init(stage);
			SReferenceManager.getInstance();
			SPreLoad.getInstance();
			SResourceMagnger.getInstance();
			SGameSocket.getInstance();
			SoundManager.getInstance();
			STimeControl.getInstance();
			ManagerGameCreate.getInstance();
		}

		protected function onResizeHandler(event : Event) : void
		{
			Config.screenWidth = current_stage.stageWidth;
			Config.screenHeight = current_stage.stageHeight;
			GameDispatcher.dispatch(GameDispatcher.RESIZE);
		}

		protected function onRightClickHandler(event : Event) : void
		{

		}

	}
}