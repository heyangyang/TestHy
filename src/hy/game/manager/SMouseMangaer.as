package hy.game.manager
{
	import flash.display.BitmapData;
	import flash.display.Stage;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.ui.Mouse;
	import flash.ui.MouseCursorData;
	import flash.utils.Dictionary;

	import hy.game.cfg.Config;
	import hy.game.utils.SDebug;


	/**
	 * 鼠标
	 * @author wait
	 *
	 */
	public class SMouseMangaer extends SBaseManager
	{
		/**
		 * 相对于舞台鼠标的位置
		 */
		private static var m_stageX : int;
		private static var m_stageY : int;

		public static function get stageX() : int
		{
			return m_stageX;
		}

		public static function get stageY() : int
		{
			return m_stageY;
		}

		private static var mouse_dic : Dictionary = new Dictionary();

		public function SMouseMangaer()
		{
			super();
		}

		public static function init(stage : Stage) : void
		{
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMoveHandler);
		}

		protected static function onMouseMoveHandler(event : MouseEvent) : void
		{
			m_stageX = event.stageX;
			m_stageY = event.stageY;
		}


		public static function registerd(type : String, types : Vector.<BitmapData>, frameRate : int = -1) : void
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


		public static function setMouseType(type : String) : void
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