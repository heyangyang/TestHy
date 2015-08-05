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
	import hy.game.components.SMouseComponent;
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
		private static var m_stageX : int;
		private static var m_stageY : int;

		public static function get mouseX() : int
		{
			return m_stageX;
		}

		public static function get mouseY() : int
		{
			return m_stageY;
		}

		private static var m_mouseComponents : Vector.<SMouseComponent> = new Vector.<SMouseComponent>();
		private static var m_numComponent : int = 0;

		public static function addComponent(com : SMouseComponent) : void
		{
			if (m_mouseComponents.indexOf(com) == -1)
			{
				m_numComponent++;
				m_mouseComponents.push(com);
			}
		}

		public static function removeComponent(com : SMouseComponent) : void
		{
			var index : int = m_mouseComponents.indexOf(com);
			if (index != -1)
			{
				m_numComponent--;
				m_mouseComponents.splice(index, 1);
			}
		}

		private var mouse_dic : Dictionary = new Dictionary();
		private var m_updateComponent : SMouseComponent;
		private var m_currComponent : SMouseComponent;
		/**
		 * 鼠标位置相对于屏幕
		 */
		private var m_lastScreenMouseX : int = -1;
		private var m_lastScreenMouseY : int = -1;
		/**
		 * 鼠标位置相对于场景
		 */
		private var m_lastSceneMouseX : int = -1;
		private var m_lastSceneMouseY : int = -1;

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
			if (m_lastScreenMouseX == mouseX && m_lastScreenMouseY == mouseY)
				return;
			m_lastScreenMouseX = SMouseUpdateMangaer.mouseX;
			m_lastScreenMouseY = SMouseUpdateMangaer.mouseY;
			m_lastSceneMouseX = SCameraObject.sceneX + m_lastScreenMouseX;
			m_lastSceneMouseY = SCameraObject.sceneY + m_lastScreenMouseY;
			m_currComponent = null;
			for (var i : int = 0; i < m_numComponent; i++)
			{
				m_updateComponent = m_mouseComponents[i];
				m_updateComponent.isMouseOver = false;
				if (!m_updateComponent.checkIsMouseIn(m_lastSceneMouseX, m_lastSceneMouseY))
					continue;
				if (!m_updateComponent.checkPixelIn(m_lastSceneMouseX, m_lastSceneMouseY))
					continue;
				if (m_currComponent == null || m_updateComponent.index > m_currComponent.index)
					m_currComponent = m_updateComponent;
			}
			if (m_currComponent)
				m_currComponent.isMouseOver = true;
		}

		public function get target():GameObject
		{
			if(m_currComponent==null)
				return null;
			return m_currComponent.gameObject;
		}
		
		protected function onMouseMoveHandler(event : MouseEvent) : void
		{
			m_stageX = event.stageX;
			m_stageY = event.stageY;
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