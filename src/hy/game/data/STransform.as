package hy.game.data
{
	import flash.geom.ColorTransform;

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
		private var mScreenX : Number;
		private var mScreenY : Number;

		private var mX : Number;
		private var mY : Number;
		private var mZ : Number = 0;
		private var mCenterOffsetY : int;
		private var mPositionCall : SCall;

		private var mWidth : int;
		private var mHeight : int;
		private var mScale : Number;
		private var mSizeCall : SCall;

		private var mAlpha : Number;

		private var mFilters : Array;
		private var mTransform : ColorTransform;
		private var mBlendMode : String;

		public var dir : int;

		private var mMouseRectangle : SRectangle;

		name_part var mAddX : Number;
		name_part var mAddY : Number;

		public var isMouseOver : Boolean;

		public function STransform()
		{
			mMouseRectangle = new SRectangle();
			mPositionCall = new SCall();
			mSizeCall = new SCall();
		}

		public function get x() : Number
		{
			return mX;
		}

		public function set x(value : Number) : void
		{
			mScreenX = value - SCameraObject.sceneX;
			if (mX == value)
				return;
			if (value < 0)
				value = 0;
			mX = value;
			mPositionCall.callUpdate();
		}

		public function get y() : Number
		{
			return mY;
		}

		public function set y(value : Number) : void
		{
			mScreenY = mY - SCameraObject.sceneY;
			if (mY == value)
				return;
			if (value < 0)
				value = 0;
			mY = value;
			mPositionCall.callUpdate();
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
			mPositionCall.callUpdate();
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

		/**
		 * 相对于屏幕的位置Y
		 * @return
		 *
		 */
		public function get screenY() : Number
		{
			return mScreenY;
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
			mPositionCall.callUpdate();
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
			mSizeCall.callUpdate();
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

		public function get filters() : Array
		{
			return mFilters;
		}

		public function set filters(value : Array) : void
		{
			if (mFilters == value)
				return;
			mFilters = value;
		}

		public function get transform() : ColorTransform
		{
			return mTransform;
		}

		public function set transform(value : ColorTransform) : void
		{
			if (mTransform == value)
				return;
			mTransform = value;
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
			mSizeCall.callUpdate();
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
			mSizeCall.callUpdate();
		}

		public function get height() : int
		{
			return mHeight;
		}

		public function get rectangle() : SRectangle
		{
			return mMouseRectangle;
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
			if (x < mX + mMouseRectangle.x || x > mX + mMouseRectangle.right)
				return false;
			if (y < mY + mMouseRectangle.y || y > mY + mMouseRectangle.bottom)
				return false;
			return true;
		}

		public function excuteNotify(update : Boolean = false) : void
		{
			mPositionCall.excuteNotify(update);
			mSizeCall.excuteNotify(update);
		}

		/**
		 * 位置有变化
		 * @param fun
		 *
		 */
		public function addPositionChange(fun : Function, index : int = -1) : void
		{
			mPositionCall.addNotify(fun, index);
		}

		/**
		 * 大小有变化
		 * @param fun
		 *
		 */
		public function addSizeChange(fun : Function) : void
		{
			mSizeCall.addNotify(fun);
		}

		public function clearCall() : void
		{
			mPositionCall.clearNotify();
			mSizeCall.clearNotify();
		}
	}
}