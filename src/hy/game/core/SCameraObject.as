package hy.game.core
{
	import hy.game.data.SCameraRectangle;
	import hy.game.data.STransform;
	import hy.game.enum.EnumPriority;
	import hy.game.namespaces.name_part;

	use namespace name_part;

	/**
	 * 摄像机
	 * @author hyy
	 *
	 */
	public class SCameraObject extends GameObject
	{
		private static var instance : SCameraObject;

		private static var m_sceneX : int;

		/**
		 * 物体在场景的位置X
		 */
		public static function get sceneX() : int
		{
			return m_sceneX;
		}

		private static var m_sceneY : int;

		/**
		 * 物体在场景的位置Y
		 */
		public static function get sceneY() : int
		{
			return m_sceneY;
		}

		private static var m_isMoving : Boolean;

		/**
		 * 镜头是否移动
		 * @return
		 *
		 */
		public static function get isMoving() : Boolean
		{
			return m_isMoving;
		}

		private static var visualRect : SCameraRectangle = new SCameraRectangle();

		/**
		 * 是否在场景内
		 * @return
		 *
		 */
		public static function isInScreen(transform : STransform) : Boolean
		{
			if (transform.x < visualRect.x || transform.x > visualRect.width)
				return false;
			if (transform.y < visualRect.y || transform.y > visualRect.height)
				return false;
			return true;
		}

		public static function getInstance() : SCameraObject
		{
			if (instance == null)
				instance = new SCameraObject();
			return instance;
		}

		private var m_current : GameObject;
		private var m_transform : STransform;
		/**
		 * 可是范围
		 */
		private var m_visualRange : SCameraRectangle;
		/**
		 * 可以移动的范围
		 */
		private var m_walkRange : SCameraRectangle;
		/**
		 * 屏幕大小
		 */
		private var m_screenW : int;
		private var m_screenH : int;
		/**
		 * 物体在屏幕的位置
		 */
		private var m_screenX : int;
		private var m_screenY : int;

		private var m_sceneW : int;
		private var m_sceneH : int;

		private var m_isChange : Boolean;

		public function SCameraObject()
		{
			if (instance)
				error(this, "only one");
			m_walkRange = new SCameraRectangle();
			m_visualRange = new SCameraRectangle();
		}

		override public function registerd(priority : int = EnumPriority.PRIORITY_0) : void
		{
			super.registerd(priority);
			removeRender(m_render);
		}

		/**
		 * 设置镜头跟随的对象
		 * @param gameObject
		 *
		 */
		public function setGameFocus(gameObject : GameObject) : void
		{
			this.m_current = gameObject;
			this.m_transform = gameObject.transform;
			m_isChange = true;
		}

		/**
		 * 设置屏幕大小
		 * @param w
		 * @param h
		 *
		 */
		public function setScreenSize(w : int, h : int) : void
		{
			this.m_screenW = w;
			this.m_screenH = h;
			//默认设置屏幕的80%为可视范围
			updateVisualRange(w * .8, h * .8);
			m_isChange = true;
		}

		/**
		 * 场景大小
		 * @param w
		 * @param h
		 *
		 */
		public function setSceneSize(w : int, h : int) : void
		{
			m_sceneW = w;
			m_sceneH = h;
			m_isChange = true;
		}

		/**
		 * 可移动范围，相对屏幕
		 * @param w
		 * @param h
		 *
		 */
		public function updateRectangle(w : int, h : int) : void
		{
			m_walkRange.updateRectangle((m_screenW - w) * .5, (m_screenH - h) * .5, w, h);
			m_isChange = true;
		}

		/**
		 * 可视范围，相对于屏幕
		 * @param w
		 * @param h
		 *
		 */
		public function updateVisualRange(w : int, h : int) : void
		{
			m_visualRange.updateRectangle((m_screenW - w) * .5, (m_screenH - h) * .5, w, h);
		}

		override public function update() : void
		{
			m_isMoving = false;
			if (m_transform == null)
				return;
			if (!m_isChange && m_transform.mx == 0 && m_transform.my == 0)
				return;

			if (m_isChange)
			{
				m_isChange = false;
				m_sceneX = m_transform.x - m_screenW * .5;
				m_sceneY = m_transform.y - m_screenH * .5;
			}

			m_isMoving = true;

			//屏幕相对位置
			m_screenX = m_transform.x - sceneX;
			m_screenY = m_transform.y - sceneY;

			//往左走
			if (m_screenX < m_walkRange.x)
			{
				m_sceneX += m_transform.mx;
			}
			//往右走
			else if (m_screenX > m_walkRange.x + m_walkRange.width)
			{
				m_sceneX += m_transform.mx;
			}

			//往上走
			if (m_screenY < m_walkRange.y)
			{
				m_sceneY += m_transform.my;
			}
			//往下走
			else if (m_screenY > m_walkRange.y + m_walkRange.height)
			{
				m_sceneY += m_transform.my;
			}

			m_transform.my = m_transform.mx = 0;
			//检测是否超出边界
			if (sceneX < 0)
				m_sceneX = 0;
			else if (sceneX > m_sceneW - m_screenW)
				m_sceneX = m_sceneW - m_screenW;

			if (sceneY < 0)
				m_sceneY = 0;
			else if (sceneY > m_sceneH - m_screenH)
				m_sceneY = m_sceneH - m_screenH;

			//更新可视范围
			visualRect.updateRectangle(m_sceneX + m_visualRange.x, m_sceneY + m_visualRange.y, m_sceneX + m_visualRange.width, m_sceneY + m_visualRange.height);
		}

		/**
		 * 场景大小
		 */
		public function get sceneW():int
		{
			return m_sceneW;
		}

		public function get sceneH():int
		{
			return m_sceneH;
		}


	}
}