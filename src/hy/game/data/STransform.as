package hy.game.data
{
	import hy.game.core.SCall;
	import hy.game.core.SCameraObject;
	import hy.game.namespaces.name_part;

	use namespace name_part;

	/**
	 * 游戏中显示对象的数据
	 * @author hyy
	 *
	 */
	public class STransform extends SObject
	{
		private var mPositionCall : SCall;
		private var mSizeCall : SCall;
		private var mAvatarCall : SCall;
		private var mColorTransformCall : SCall;

		private var mScreenX : Number;
		private var mScreenY : Number;

		private var mX : Number;
		private var mY : Number;
		private var mZ : Number = 0;
		private var mCenterOffsetY : int;

		private var mWidth : int;
		private var mHeight : int;
		private var mScale : Number;

		private var mAlpha : Number;

		private var mFilters : *;
		private var mBlendMode : String;

		private var mRectangle : SRectangle;

		private var mDir : int;
		private var mAction : int;
		private var mIsRide : Boolean;
		public var frameIndex : int;

		public var isMouseOver : Boolean;

		public function STransform()
		{
			mRectangle = new SRectangle();
			mPositionCall = new SCall();
			mSizeCall = new SCall();
			mAvatarCall = new SCall();
			mColorTransformCall = new SCall();
		}

		public function get x() : Number
		{
			return mX;
		}

		public function set x(value : Number) : void
		{
			screenX = Math.floor(value - SCameraObject.sceneX);
			if (mX == value)
				return;
			if (value < 0)
				value = 0;
			mX = value;
			mPositionCall.updateCallStatus();
		}

		public function get y() : Number
		{
			return mY;
		}

		public function set y(value : Number) : void
		{
			screenY = Math.floor(value - SCameraObject.sceneY);
			if (mY == value)
				return;
			if (value < 0)
				value = 0;
			mY = value;
			mPositionCall.updateCallStatus();
		}

		public function get z() : Number
		{
			return mZ;
		}

		public function set z(value : Number) : void
		{
			if (mZ == value)
				return;
			mZ = value;
			mPositionCall.updateCallStatus();
		}

		/**
		 * 相对于屏幕的位置X
		 * @return
		 *
		 */
		public function get screenX() : Number
		{
			return mScreenX;
		}

		public function set screenX(value : Number) : void
		{
			if (mScreenX == value)
				return;
			mScreenX = value
			mPositionCall.updateCallStatus();
		}

		/**
		 * 相对于屏幕的位置Y
		 * @return
		 *
		 */
		public function get screenY() : Number
		{
			return mScreenY;
		}

		public function set screenY(value : Number) : void
		{
			if (mScreenY == value)
				return;
			mScreenY = value
			mPositionCall.updateCallStatus();
		}

		/**
		 * 中心点
		 * @return
		 *
		 */
		public function get centerOffsetY() : int
		{
			return mCenterOffsetY;
		}

		public function set centerOffsetY(value : int) : void
		{
			if (mCenterOffsetY == value)
				return;
			mCenterOffsetY = value;
			mPositionCall.updateCallStatus();
		}

		/**
		 * 缩放
		 * @return
		 *
		 */
		public function get scale() : Number
		{
			return mScale;
		}

		public function set scale(value : Number) : void
		{
			if (mScale == value)
				return;
			mScale = value;
			mSizeCall.updateCallStatus();
		}

		/**
		 * 透明度
		 * @return
		 *
		 */
		public function get alpha() : Number
		{
			return mAlpha;
		}

		public function set alpha(value : Number) : void
		{
			if (mAlpha == value)
				return;
			mAlpha = value;
		}

		public function get filters() : *
		{
			return mFilters;
		}

		public function set filters(value : *) : void
		{
			if (mFilters == value)
				return;
			mFilters = value;
			mColorTransformCall.updateCallStatus();
		}

		/**
		 * 混合模式
		 * @return
		 *
		 */
		public function get blendMode() : String
		{
			return mBlendMode;
		}

		public function set blendMode(value : String) : void
		{
			if (mBlendMode == value)
				return;
			mBlendMode = value;
		}

		public function set width(value : int) : void
		{
			if (mWidth == value)
				return;
			mWidth = value;
			mSizeCall.updateCallStatus();
		}

		public function get width() : int
		{
			return mWidth;
		}

		public function set height(value : int) : void
		{
			if (mHeight == value)
				return;
			mHeight = value;
			mSizeCall.updateCallStatus();
		}

		public function get height() : int
		{
			return mHeight;
		}

		public function get dir() : int
		{
			return mDir;
		}

		public function set dir(value : int) : void
		{
			if (mDir == value)
				return;
			mDir = value;
			mAvatarCall.updateCallStatus();
		}

		public function get action() : int
		{
			return mAction;
		}

		public function set action(value : int) : void
		{
			if (mAction == value)
				return;
			mAction = value;
			mAvatarCall.updateCallStatus();
		}

		public function get isRide() : Boolean
		{
			return mIsRide;
		}

		public function set isRide(value : Boolean) : void
		{
			if (mIsRide == value)
				return;
			mIsRide = value;
			mAvatarCall.updateCallStatus();
		}

		/**
		 * 显示区域大小,用于鼠标碰撞检测
		 * @return
		 *
		 */
		public function get rectangle() : SRectangle
		{
			return mRectangle;
		}

		/**
		 * 是否包含指定的点。
		 * @param x
		 * @param y
		 * @return
		 *
		 */
		public function contains(x : int, y : int) : Boolean
		{
			if (x < mX + mRectangle.x || x > mX + mRectangle.right)
				return false;
			if (y < mY + mRectangle.y || y > mY + mRectangle.bottom)
				return false;
			return true;
		}

		public function excuteNotify(update : Boolean = false) : void
		{
			mPositionCall.checkExcute(update);
			mSizeCall.checkExcute(update);
			mAvatarCall.checkExcute(update);
			mColorTransformCall.checkExcute(update);
		}

		/**
		 * 位置有变化
		 * @param fun
		 *
		 */
		public function addPositionChange(fun : Function, index : int = -1) : void
		{
			mPositionCall.push(fun, index);
		}

		/**
		 * 大小有变化
		 * @param fun
		 *
		 */
		public function addSizeChange(fun : Function) : void
		{
			mSizeCall.push(fun);
		}

		/**
		 * 人物动作，方向有改变的时候
		 * @param fun
		 *
		 */
		public function addAavatarChange(fun : Function) : void
		{
			mAvatarCall.push(fun);
		}

		/**
		 * 颜色，滤镜 改变
		 * @param fun
		 *
		 */
		public function addColorTransformChange(fun : Function) : void
		{
			mColorTransformCall.push(fun);
		}

		public function cleanCall() : void
		{
			mPositionCall.clean();
			mSizeCall.clean();
			mAvatarCall.clean();
			mColorTransformCall.clean();
		}

	}
}