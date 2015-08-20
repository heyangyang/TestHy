package hy.game

{
	import flash.display.Stage;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import hy.game.cfg.Config;
	import hy.game.core.GameDispatcher;
	import hy.game.core.SMainGameFrame;
	import hy.game.manager.SKeyboardManager;
	import hy.game.manager.SLayerManager;
	import hy.game.manager.SReferenceManager;
	import hy.game.manager.SUpdateManager;
	import hy.game.net.SGameSocket;
	import hy.game.resources.SPreLoad;
	import hy.game.resources.SResourceMagnger;
	import hy.game.sound.SoundManager;
	import hy.game.starter.SGameStartBase;
	import hy.game.update.SMouseUpdateMangaer;
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

		private var current_stage : Stage;
		private var gameStarter : SGameStartBase;

		public function GameFrameStart(stage : Stage, sarter : SGameStartBase)
		{
			gameStarter = sarter;
			current_stage = stage;
			init();
			sarter.onStart();
		}

		private function init() : void
		{
			if (m_current)
				SDebug.error("m_current != null");
			current_stage.scaleMode = StageScaleMode.NO_SCALE;
			current_stage.align = StageAlign.TOP_LEFT;
			current_stage.frameRate = Config.frameRate;
			current_stage.color = 0x000000;
			GameDispatcher.getInstance();
			current_stage.addEventListener(Event.RESIZE, onResizeHandler);
			current_stage.addEventListener(MouseEvent.RIGHT_CLICK, onRightClickHandler);
			onResizeHandler(null);
			Config.stage = current_stage;
			current_stage.focus = current_stage;
			m_current = this;
			SDebug.init(current_stage);
		}

		public function onStart() : void
		{
			SMainGameFrame.getInstance().init(current_stage);
			SMouseUpdateMangaer.getInstance().init(current_stage);
			SLayerManager.getInstance().init(current_stage);
			SKeyboardManager.getInstance().init(current_stage);
			SReferenceManager.getInstance();
			SPreLoad.getInstance();
			SResourceMagnger.getInstance();
			SGameSocket.getInstance();
			SoundManager.getInstance();
			STimeControl.getInstance();
			ManagerGameCreate.getInstance();
			//添加序列渲染
			SMainGameFrame.getInstance().addGameFrame(SLayerManager.getInstance());
			SMainGameFrame.getInstance().addGameFrame(SUpdateManager.getInstance());
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