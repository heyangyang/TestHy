package hy.game.core
{
	import hy.game.data.SPoint;
	import hy.game.data.SRectangle;
	import hy.game.data.STransform;
	import hy.game.namespaces.name_part;

	use namespace name_part;

	/**
	 * 摄像机
	 * @author hyy
	 *
	 */
	public class SCameraObject extends SUpdate
	{
		private static var instance : SCameraObject;
		private static var sVisualRect : SRectangle = new SRectangle();
		private static var sPoint : SPoint = new SPoint();
		private static var sIsMoving : Boolean;
		private static var sSceneX : Number = NaN;
		private static var sSceneY : Number = NaN;

		/**
		 * 物体在场景的位置X
		 */
		public static function get sceneX() : Number
		{
			return sSceneX;
		}

		/**
		 * 物体在场景的位置Y
		 */
		public static function get sceneY() : Number
		{
			return sSceneY;
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
		/**
		 * 人物所在屏幕的位置
		 * 在中间=0
		 */
		private var mPositionType : int;
		private const LEFT : int = Math.pow(2, 0);
		private const TOP : int = Math.pow(2, 1);
		private const RIGHT : int = Math.pow(2, 2);
		private const BOTTOM : int = Math.pow(2, 3);

		public function SCameraObject()
		{
			if (instance)
				error(this, "only one");
			mWalkRange = new SRectangle();
			mVisualRange = new SRectangle();
		}

		override public function registerd(priority : int = 0) : void
		{
			super.registerd(priority);
			GameDispatcher.addEventListener(GameDispatcher.RESIZE, onResizeHandler);
		}

		override public function unRegisterd() : void
		{
			super.unRegisterd();
			GameDispatcher.removeEventListener(GameDispatcher.RESIZE, onResizeHandler);
		}

		private function onResizeHandler() : void
		{
			mUpdatable = true;
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
			this.mTransform.addPositionChange(updatePosition, 0);
			sSceneX = mTransform.x - mScreenW * .5;
			sSceneY = mTransform.y - mScreenH * .5;
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
			if (!mUpdatable)
				return;
			mUpdatable = false;
			sSceneX = mTransform.x - mScreenW * .5;
			sSceneY = mTransform.y - mScreenH * .5;
			sIsMoving = true;
			updatePosition();
			//强制更新坐标
			mTransform.excuteNotify(true);
		}

		private function updatePosition() : void
		{
//			//往左走
//			if (mSceneX > 0 && mTransform.x < mSceneX + mWalkRange.x)
//			{
//				mSceneX += mTransform.mAddX;
//			}
//			//往右走
//			else if (mTransform.x > mSceneX + mWalkRange.right && mSceneX < mSceneW - mScreenW)
//			{
//				mSceneX += mTransform.mAddX;
//			}
//
//			//往上走
//			if (mSceneY > 0 && mTransform.y < mSceneY + mWalkRange.y)
//			{
//				mSceneY += mTransform.mAddY;
//			}
//			//往下走
//			else if (mTransform.y > mSceneY + mWalkRange.bottom && mSceneY < mSceneH - mScreenH)
//			{
//				mSceneY += mTransform.mAddY;
//			}
//
//			mTransform.mAddY = mTransform.mAddX = 0.0;

			//绑定人物在屏幕中间
			sSceneX = mTransform.x - (mScreenW >> 1);
			sSceneY = mTransform.y - (mScreenH >> 1);
			mPositionType = 0;
			//检测是否超出边界
			if (sSceneX < 0)
			{
				sSceneX = 0;
				mPositionType += LEFT;
			}
			else if (sSceneX + mScreenW > mSceneW)
			{
				sSceneX = mSceneW - mScreenW;
				mPositionType += RIGHT;
			}
			if (sSceneY < 0)
			{
				sSceneY = 0;
				mPositionType += TOP;
			}
			else if (sSceneY + mScreenH > mSceneH)
			{
				sSceneY = mSceneH - mScreenH;
				mPositionType += BOTTOM;
			}
			//更新可视范围
			sVisualRect.updateRectangle(mPositionType & LEFT ? 0 : sSceneX + mVisualRange.x, mPositionType & TOP ? 0 : sSceneY + mVisualRange.y, mPositionType & RIGHT ? mSceneW - sSceneX - mVisualRange.x : mVisualRange.width, mPositionType & BOTTOM ? mSceneH - sSceneY - mVisualRange.y : mVisualRange.height);
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