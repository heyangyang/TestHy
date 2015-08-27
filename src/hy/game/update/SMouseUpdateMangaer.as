package hy.game.update
{
	import flash.display.BitmapData;
	import flash.display.Stage;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.ui.Mouse;
	import flash.ui.MouseCursorData;
	import flash.utils.Dictionary;
	
	import hy.game.cfg.Config;
	import hy.game.components.SCollisionComponent;
	import hy.game.core.GameObject;
	import hy.game.core.SCameraObject;
	import hy.game.core.SUpdate;
	import hy.game.utils.SDebug;


	/**
	 * 鼠标管理器
	 * @author wait
	 *
	 */
	public class SMouseUpdateMangaer extends SUpdate
	{
		private static var instance : SMouseUpdateMangaer;

		public static function getInstance() : SMouseUpdateMangaer
		{
			if (!instance)
				instance = new SMouseUpdateMangaer();
			return instance;
		}
		/**
		 * 相对于舞台鼠标的位置
		 */
		private static var mStageX : int;
		private static var mStageY : int;

		public static function get mouseX() : int
		{
			return mStageX;
		}

		public static function get mouseY() : int
		{
			return mStageY;
		}

		private static var mMouseComponents : Vector.<SCollisionComponent> = new Vector.<SCollisionComponent>();
		private static var mNumComponent : int = 0;

		public static function addComponent(com : SCollisionComponent) : void
		{
			if (mMouseComponents.indexOf(com) == -1)
			{
				mNumComponent++;
				mMouseComponents.push(com);
			}
		}

		public static function removeComponent(com : SCollisionComponent) : void
		{
			var index : int = mMouseComponents.indexOf(com);
			if (index != -1)
			{
				mNumComponent--;
				mMouseComponents.splice(index, 1);
			}
		}

		private var mouse_dic : Dictionary = new Dictionary();
		private var mUpdateComponent : SCollisionComponent;
		private var mCurrComponent : SCollisionComponent;
		/**
		 * 鼠标位置相对于屏幕
		 */
		private var mLastScreenMouseX : int = -1;
		private var mLastScreenMouseY : int = -1;
		/**
		 * 鼠标位置相对于场景
		 */
		private var mLastSceneMouseX : int = -1;
		private var mLastSceneMouseY : int = -1;

		public function SMouseUpdateMangaer()
		{
			super();
			frameInterval = 100;
		}

		public function init(stage : Stage) : void
		{
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMoveHandler);
			registerd();
		}

		override public function update() : void
		{
			if (mLastScreenMouseX == mouseX && mLastScreenMouseY == mouseY)
				return;
			mLastScreenMouseX = SMouseUpdateMangaer.mouseX;
			mLastScreenMouseY = SMouseUpdateMangaer.mouseY;
			mLastSceneMouseX = SCameraObject.sceneX + mLastScreenMouseX;
			mLastSceneMouseY = SCameraObject.sceneY + mLastScreenMouseY;
			mCurrComponent = null;
			for (var i : int = 0; i < mNumComponent; i++)
			{
				mUpdateComponent = mMouseComponents[i];
				mUpdateComponent.isMouseOver = false;
				if (!mUpdateComponent.checkIsMouseIn(mLastSceneMouseX, mLastSceneMouseY))
					continue;
				if (!mUpdateComponent.checkPixelIn(mLastSceneMouseX, mLastSceneMouseY))
					continue;
				if (mCurrComponent == null || mUpdateComponent.index > mCurrComponent.index)
					mCurrComponent = mUpdateComponent;
			}
			if (mCurrComponent)
				mCurrComponent.isMouseOver = true;
		}

		public function get target():GameObject
		{
			if(mCurrComponent==null)
				return null;
			return mCurrComponent.gameObject;
		}
		
		protected function onMouseMoveHandler(event : MouseEvent) : void
		{
			mStageX = event.stageX;
			mStageY = event.stageY;
		}

		public function registerMouse(type : String, types : Vector.<BitmapData>, frameRate : int = -1) : void
		{
			if (mouse_dic[type])
			{
				SDebug.warning("mouse type is exist:" + type);
				return;
			}
			var mouseData : MouseCursorData = new MouseCursorData();
			mouseData.hotSpot = new Point();
			mouseData.data = types;
			if (frameRate == -1)
				frameRate = Config.frameRate;
			mouseData.frameRate = frameRate;
			mouse_dic[type] = mouseData;
		}


		public function setMouseType(type : String) : void
		{
			var mouseData : MouseCursorData = mouse_dic[type];
			if (mouseData == null)
			{
				SDebug.warning("not find mouse type:" + type);
				return;
			}
			Mouse.registerCursor(type, mouseData);
		}
	}
}