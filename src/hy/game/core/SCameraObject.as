package hy.game.core
{
	import hy.game.data.SCameraRectangle;
	import hy.game.data.STransform;
	import hy.game.enum.EnumPriority;

	/**
	 * 摄像机
	 * @author hyy
	 *
	 */
	public class SCameraObject extends GameObject
	{
		private static var instance : SCameraObject;

		public static function getInstance() : SCameraObject
		{
			if (instance == null)
				instance = new SCameraObject();
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
		public static var sceneX : int;
		public static  var sceneY : int;
		public static var updateAble:Boolean;
		/**
		 * 场景大小
		 */
		private var m_sceneW : int;
		private var m_sceneH : int;
		/**
		 * x，y 移动速度
		 */
		protected var m_velocityX : Number=0;
		protected var m_velocityY : Number=0;

		private var m_isChange : Boolean;
		
		public function SCameraObject()
		{
			if (instance)
				error(this, "only one");
			m_rectangle = new SCameraRectangle();
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
			updateAble=false;
			if (m_transform == null)
				return;
			if (!m_isChange && m_velocityX == 0 && m_velocityY == 0)
				return;
			
			if (m_isChange)
			{
				m_isChange = false;
				sceneX = m_transform.x - m_screenW * .5;
				sceneY = m_transform.y - m_screenH * .5;
			}

			updateAble=true;
			
			//屏幕相对位置
			m_screenX =   m_transform.x-sceneX;
			m_screenY =   m_transform.y-sceneY;

			//往左走
			if (m_screenX < m_rectangle.x)
			{
				sceneX += -m_velocityX * STime.deltaTime;
			}
			//往右走
			else if (m_screenX > m_rectangle.x + m_rectangle.width)
			{
				sceneX += m_velocityX * STime.deltaTime;
			}

			//往上走
			if (m_screenY < m_rectangle.y)
			{
				sceneY += -m_velocityY * STime.deltaTime;
			}
			//往下走
			else if (m_screenY > m_rectangle.y + m_rectangle.height)
			{
				sceneY += m_velocityY * STime.deltaTime;
			}

			//检测是否超出边界
			if (sceneX < 0)
				sceneX = 0;
			else if (sceneX > m_sceneW - m_screenW)
				sceneX = m_sceneW - m_screenW;

			if (sceneY < 0)
				sceneY = 0;
			else if (sceneY > m_sceneH - m_screenH)
				sceneY = m_sceneH - m_screenH;
		}
	}
}