package hy.game.data
{
	import flash.geom.ColorTransform;

	import hy.game.core.SCameraObject;
	import hy.game.core.interfaces.IRender;
	import hy.game.namespaces.name_part;

	use namespace name_part;

	/**
	 * 游戏中显示对象的数据
	 * @author hyy
	 *
	 */
	public class STransform extends SObject
	{
		public static const C_XYZ : int = Math.pow(2, 0);
		public static const C_WH : int = Math.pow(2, 1);
		public static const C_ALPHA : int = Math.pow(2, 2);

		private var mScreenX : int;
		private var mScreenY : int;

		private var mX : int;
		private var mY : int;
		private var mZ : int;
		private var mCenterOffsetY : int;

		private var mScale : Number;

		private var mAlpha : Number;

		private var mFilters : Array;

		private var mTransform : ColorTransform;

		private var mBlendMode : String;

		private var mWidth : int;
		private var mHeight : int;

		private var mChange : int;

		public var dir : int;

		private var mRectangle : SRectangle;

		name_part var mAddX : int;
		name_part var mAddY : int;

		public var isMouseOver : Boolean;

		public function STransform()
		{
			mRectangle = new SRectangle();
		}

		public function get rectangle() : SRectangle
		{
			return mRectangle;
		}

		public function get x() : int
		{
			return mX;
		}

		public function set x(value : int) : void
		{
			mScreenX = value - SCameraObject.sceneX;
			if (mX == value)
				return;
			if (value < 0)
				value = 0;
			mX = value;
			if ((mChange & C_XYZ) == 0)
				mChange += C_XYZ;
		}

		public function get y() : int
		{
			return mY;
		}

		public function set y(value : int) : void
		{
			if (mY == value)
				return;
			if (value < 0)
				value = 0;
			mY = value;
			mScreenY = mY - SCameraObject.sceneY;
			if ((mChange & C_XYZ) == 0)
				mChange += C_XYZ;
		}

		public function get z() : int
		{
			return mZ;
		}

		public function set z(value : int) : void
		{
			if (mZ == value)
				return;
			mZ = value;
			if ((mChange & C_XYZ) == 0)
				mChange += C_XYZ;
		}

		public function get screenX() : int
		{
			return mScreenX;
		}

		public function get screenY() : int
		{
			return mScreenY;
		}

		public function get centerOffsetY() : int
		{
			return mCenterOffsetY;
		}

		public function set centerOffsetY(value : int) : void
		{
			if (mCenterOffsetY == value)
				return;
			mCenterOffsetY = value;
			if ((mChange & C_XYZ) == 0)
				mChange += C_XYZ;
		}

		public function get scale() : Number
		{
			return mScale;
		}

		public function set scale(value : Number) : void
		{
			if (mScale == value)
				return;
			mScale = value;
		}

		public function get alpha() : Number
		{
			return mAlpha;
		}

		public function set alpha(value : Number) : void
		{
			if (mAlpha == value)
				return;
			mAlpha = value;
			if ((mChange & C_ALPHA) == 0)
				mChange += C_ALPHA;
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

		public function isChangeFiled(key : int) : Boolean
		{
			return (mChange & key) != 0;
		}

		public function set width(value : int) : void
		{
			if (mWidth == value)
				return;
			mWidth = value;
			if ((mChange & C_WH) == 0)
				mChange += C_WH;
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
			if ((mChange & C_WH) == 0)
				mChange += C_WH;
		}

		public function get height() : int
		{
			return mHeight;
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

		public function updateRender(render : IRender) : void
		{
			if (isChangeFiled(C_XYZ))
			{
				render.x = mX;
				render.y = mY;
			}
			if (isChangeFiled(C_ALPHA))
				render.alpha = mAlpha;
		}

		name_part function changAll() : void
		{
			mChange = 0;
			mChange += C_XYZ;
			mChange += C_WH;
			mChange += C_ALPHA;
		}

		/**
		 * 改变后清零
		 *
		 */
		name_part function hasChanged() : void
		{
			mChange = 0;
		}
	}
}