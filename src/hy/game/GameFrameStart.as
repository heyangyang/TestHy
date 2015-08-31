package hy.game

{
	import flash.display.Stage;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	import hy.game.cfg.Config;
	import hy.game.core.GameDispatcher;
	import hy.game.core.SMainGameFrame;
	import hy.game.manager.GameObjectManager;
	import hy.game.manager.SKeyboardManager;
	import hy.game.manager.SLayerManager;
	import hy.game.manager.SReferenceManager;
	import hy.game.manager.SUpdateManager;
	import hy.game.net.SGameSocket;
	import hy.game.resources.SPreLoad;
	import hy.game.resources.SResourceMagnger;
	import hy.game.sound.SoundManager;
	import hy.game.stage3D.SStage3D;
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
		private static var mCurrent : GameFrameStart;

		public static function get current() : GameFrameStart
		{
			return mCurrent
		}

		private var mCurrentStage : Stage;
		private var mGameStarter : SGameStartBase;

		public function GameFrameStart(stage : Stage, sarter : SGameStartBase)
		{
			mGameStarter = sarter;
			mCurrentStage = stage;
			init();
			sarter.onStart();
		}

		private function init() : void
		{
			if (mCurrent)
				SDebug.error("mCurrent != null");
			mCurrentStage.scaleMode = StageScaleMode.NO_SCALE;
			mCurrentStage.align = StageAlign.TOP_LEFT;
			mCurrentStage.frameRate = Config.frameRate;
			mCurrentStage.color = 0x000000;
			GameDispatcher.getInstance();
			mCurrentStage.addEventListener(Event.RESIZE, onResizeHandler);
			mCurrentStage.addEventListener(MouseEvent.RIGHT_CLICK, onRightClickHandler);
			onResizeHandler(null);
			Config.stage = mCurrentStage;
			mCurrentStage.focus = mCurrentStage;
			mCurrent = this;
			SDebug.init(mCurrentStage);
		}

		public function onStart() : void
		{
			SMainGameFrame.getInstance().init(mCurrentStage);
			SMouseUpdateMangaer.getInstance().init(mCurrentStage);
			SLayerManager.getInstance().init(mCurrentStage);
			SKeyboardManager.getInstance().init(mCurrentStage);
			SReferenceManager.getInstance();
			SPreLoad.getInstance();
			SResourceMagnger.getInstance();
			SGameSocket.getInstance();
			SoundManager.getInstance();
			STimeControl.getInstance();
			ManagerGameCreate.getInstance();
			//添加序列渲染
			SMainGameFrame.getInstance().addGameFrame(GameObjectManager.getInstance());
			SMainGameFrame.getInstance().addGameFrame(SUpdateManager.getInstance());
		}

		protected function onResizeHandler(event : Event) : void
		{
			Config.screenWidth = mCurrentStage.stageWidth;
			Config.screenHeight = mCurrentStage.stageHeight;
			GameDispatcher.dispatch(GameDispatcher.RESIZE);
			if (SStage3D.current)
				SStage3D.current.viewPort = new Rectangle(0, 0, Config.screenWidth, Config.screenHeight);
		}

		protected function onRightClickHandler(event : Event) : void
		{

		}

	}
}