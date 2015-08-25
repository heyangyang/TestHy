package hy.game.core
{
	import hy.game.data.SPoint;
	import hy.game.data.SRectangle;
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
		private static var sVisualRect : SRectangle = new SRectangle();
		private static var sPoint : SPoint = new SPoint();
		private static var sIsMoving : Boolean;
		private static var mSceneX : int = int.MIN_VALUE;
		private static var mSceneY : int = int.MIN_VALUE;

		/**
		 * 物体在场景的位置X
		 */
		public static function get sceneX() : int
		{
			return mSceneX;
		}

		/**
		 * 物体在场景的位置Y
		 */
		public static function get sceneY() : int
		{
			return mSceneY;
		}

		/**
		 * 镜头是否移动
		 * @return
		 *
		 */
		public static function get isMoving() : Boolean
		{
			return sIsMoving;
		}

		/**
		 * 获得可视范围内的一点
		 * @return
		 *
		 */
		public static function getVisualPoint() : SPoint
		{
			sPoint.x = sVisualRect.x + Math.random() * sVisualRect.width;
			sPoint.y = sVisualRect.y + Math.random() * sVisualRect.height;
			return sPoint;
		}

		/**
		 * 是否在场景内
		 * @return
		 *
		 */
		public static function isInScreen(transform : STransform) : Boolean
		{
			if (transform.x < sVisualRect.x || transform.x > sVisualRect.right)
				return false;
			if (transform.y < sVisualRect.y || transform.y > sVisualRect.bottom)
				return false;
			return true;
		}

		public static function getInstance() : SCameraObject
		{
			if (instance == null)
				instance = new SCameraObject();
			return instance;
		}

		private var mCurrent : GameObject;
		private var mTransform : STransform;
		/**
		 * 可是范围
		 */
		private var mVisualRange : SRectangle;
		/**
		 * 可以移动的范围
		 */
		private var mWalkRange : SRectangle;
		/**
		 * 屏幕大小
		 */
		private var mScreenW : int;
		private var mScreenH : int;
		/**
		 * 场景大小 
		 */
		private var mSceneW : int;
		private var mSceneH : int;
		/**
		 * 是否需要更新
		 * true立马更新物体在场景的位置
		 */
		private var mUpdatable : Boolean;

		public function SCameraObject()
		{
			if (instance)
				error(this, "only one");
			mWalkRange = new SRectangle();
			mVisualRange = new SRectangle();
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
			this.mCurrent = gameObject;
			this.mTransform = gameObject.transform;
			mUpdatable = true;
		}

		/**
		 * 设置屏幕大小
		 * @param w
		 * @param h
		 *
		 */
		public function setScreenSize(w : int, h : int) : void
		{
			this.mScreenW = w;
			this.mScreenH = h;
			//默认设置屏幕的80%为可视范围
			updateVisualRange(w * .8, h * .8);
			mUpdatable = true;
		}

		/**
		 * 场景大小
		 * @param w
		 * @param h
		 *
		 */
		public function setSceneSize(w : int, h : int) : void
		{
			mSceneW = w;
			mSceneH = h;
			mUpdatable = true;
		}

		/**
		 * 可移动范围，相对屏幕
		 * @param w
		 * @param h
		 *
		 */
		public function updateRectangle(w : int, h : int) : void
		{
			mWalkRange.updateRectangle((mScreenW - w) * .5, (mScreenH - h) * .5, w, h);
			mUpdatable = true;
		}

		/**
		 * 可视范围，相对于屏幕
		 * @param w
		 * @param h
		 *
		 */
		public function updateVisualRange(w : int, h : int) : void
		{
			mVisualRange.updateRectangle((mScreenW - w) * .5, (mScreenH - h) * .5, w, h);
		}

		override public function update() : void
		{
			sIsMoving = false;
			if (mTransform == null)
				return;
			if (!mUpdatable && mTransform.mAddX == 0 && mTransform.mAddY == 0)
				return;

			if (mUpdatable)
			{
				mUpdatable = false;
				mSceneX = mTransform.x - mScreenW * .5;
				mSceneY = mTransform.y - mScreenH * .5;
			}

			sIsMoving = true;

			//往左走
			if (mSceneX > 0 && mTransform.x < mSceneX + mWalkRange.x)
			{
				mSceneX += mTransform.mAddX;
			}
			//往右走
			else if (mTransform.x > mSceneX + mWalkRange.right && mSceneX < mSceneW - mScreenW)
			{
				mSceneX += mTransform.mAddX;
			}

			//往上走
			if (mSceneY > 0 && mTransform.y < mSceneY + mWalkRange.y)
			{
				mSceneY += mTransform.mAddY;
			}
			//往下走
			else if (mTransform.y > mSceneY + mWalkRange.bottom && mSceneY < mSceneH - mScreenH)
			{
				mSceneY += mTransform.mAddY;
			}

			mTransform.mAddY = mTransform.mAddX = 0;
			//检测是否超出边界
			if (mSceneX < 0)
				mSceneX = 0;
			else if (mSceneX + mScreenW > mSceneW)
				mSceneX = mSceneW - mScreenW;

			if (mSceneY < 0)
				mSceneY = 0;
			else if (mSceneY + mScreenH > mSceneH)
				mSceneY = mSceneH - mScreenH;

			//更新可视范围
			sVisualRect.updateRectangle(mSceneX + mVisualRange.x, mSceneY + mVisualRange.y + 120, mVisualRange.width, mVisualRange.height - 120);
		}

		/**
		 * 场景大小
		 */
		public function get sceneW() : int
		{
			return mSceneW;
		}

		public function get sceneH() : int
		{
			return mSceneH;
		}

		/**
		 * 屏幕大小
		 * @return
		 *
		 */
		public function get screenW() : int
		{
			return mScreenW;
		}

		public function get screenH() : int
		{
			return mScreenH;
		}

	}
}