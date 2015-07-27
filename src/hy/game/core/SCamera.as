package hy.game.core
{
	import hy.game.cfg.Time;
	import hy.game.data.SCameraRectangle;
	import hy.game.data.STransform;

	/**
	 * 摄像机
	 * @author hyy
	 *
	 */
	public class SCamera extends GameObject
	{
		private static var instance : SCamera;

		public static function getInstance() : SCamera
		{
			if (instance)
				instance = new SCamera();
			return instance;
		}

		private var m_current : GameObject;
		private var m_transform : STransform;
		private var m_rectangle : SCameraRectangle;

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
		/**
		 * 物体在场景的位置
		 */
		private var m_sceneX : int;
		private var m_sceneY : int;
		/**
		 * 场景大小
		 */
		private var m_sceneW : int;
		private var m_sceneH : int;
		/**
		 * x，y 移动速度
		 */
		protected var m_velocityX : Number;
		protected var m_velocityY : Number;

		private var m_isChange : Boolean;

		public function SCamera()
		{
			if (instance)
				error(this, "only one");
			m_rectangle = new SCameraRectangle();
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
			m_rectangle.updateRectangle((m_screenW - w) * .5, (m_screenH - h) * .5, w, h);
			m_isChange = true;
		}

		override public function update() : void
		{
			if (m_transform == null)
				return;
			if (m_velocityX == 0 && m_velocityY == 0)
				return;
			if (m_isChange)
			{
				m_isChange = false;
				m_sceneX = m_transform.x - m_screenH * .5;
				m_sceneY = m_transform.y - m_screenH * .5;
			}

			if (m_velocityY == 0 && m_velocityY == 0)
				return;

			//屏幕相对位置
			m_screenX = m_sceneX - m_transform.x;
			m_screenY = m_sceneY - m_transform.y;

			//往左走
			if (m_screenX < m_rectangle.x)
			{
				m_sceneX += -m_velocityX * Time.deltaTime;
			}
			//往右走
			else if (m_screenX > m_rectangle.x + m_rectangle.width)
			{
				m_sceneX += m_velocityX * Time.deltaTime;
			}

			//往上走
			if (m_screenY < m_rectangle.y)
			{
				m_sceneY += -m_velocityY * Time.deltaTime;
			}
			//往下走
			else if (m_screenY > m_rectangle.y + m_rectangle.height)
			{
				m_sceneY += m_velocityY * Time.deltaTime;
			}

			//检测是否超出边界
			if (m_sceneX < 0)
				m_sceneX = 0;
			else if (m_sceneX > m_sceneW - m_screenW)
				m_sceneX = m_sceneW - m_screenW;

			if (m_sceneY < 0)
				m_sceneY = 0;
			else if (m_sceneY > m_sceneH - m_screenH)
				m_sceneY = m_sceneH - m_screenH;
		}

		public function get sceneX() : int
		{
			return m_sceneX;
		}

		public function get sceneY() : int
		{
			return m_sceneY;
		}

	}
}