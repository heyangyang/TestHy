package hy.game.stage3D.display
{
	import hy.game.interfaces.display.IDisplayObject;
	import hy.game.interfaces.display.IDisplayObjectContainer;
	import hy.game.stage3D.errors.AbstractMethodError;
	import hy.game.stage3D.texture.SBlendMode;
	import hy.game.stage3D.utils.SMathUtil;



	public class SDisplayObject implements IDisplayObject
	{
		private var mX : Number;
		private var mY : Number;
		private var mScaleX : Number;
		private var mScaleY : Number;
		private var mRotation : Number;
		private var mAlpha : Number;
		private var mVisible : Boolean;
		private var mTouchable : Boolean;
		private var mBlendMode : String;
		private var mName : String;
		private var mParent : IDisplayObjectContainer;
		protected var mOrientationChanged : Boolean;
		/**
		 * 记录索引位置
		 */
		private var mLayer : int;

		public function SDisplayObject()
		{
			super();
			mX = mY = mRotation = 0.0;
			mScaleX = mScaleY = mAlpha = 1.0;
			mVisible = mTouchable = true;
			mBlendMode = SBlendMode.AUTO;
			mOrientationChanged = false;
		}

		public function render() : void
		{
			throw new AbstractMethodError();
		}

		public function get hasVisibleArea() : Boolean
		{
			return mAlpha != 0.0 && mVisible && mScaleX != 0.0 && mScaleY != 0.0;
		}

		public function removeFromParent(dispose : Boolean = false) : void
		{
			if (mParent)
				mParent.removeDisplay(this, dispose);
			else if (dispose)
				this.dispose();
		}

		public function setParent(value : IDisplayObjectContainer) : void
		{
			mParent = value;
		}

		public function get parent() : IDisplayObjectContainer
		{
			return mParent;
		}

		public function get layer() : int
		{
			return mLayer;
		}

		public function set layer(value : int) : void
		{
			mLayer = value;
		}

		public function get x() : Number
		{
			return mX;
		}

		public function set x(value : Number) : void
		{
			if (mX != value)
			{
				mX = value;
			}
		}

		public function get y() : Number
		{
			return mY;
		}

		public function set y(value : Number) : void
		{
			if (mY != value)
			{
				mY = value;
			}
		}


		public function get scaleX() : Number
		{
			return mScaleX;
		}

		public function set scaleX(value : Number) : void
		{
			if (mScaleX != value)
			{
				mScaleX = value;
				mOrientationChanged = true;
			}
		}

		public function get scaleY() : Number
		{
			return mScaleY;
		}

		public function set scaleY(value : Number) : void
		{
			if (mScaleY != value)
			{
				mScaleY = value;
				mOrientationChanged = true;
			}
		}

		public function get rotation() : Number
		{
			return mRotation;
		}

		/**
		 * 弧度
		 * @param value
		 *
		 */
		public function set rotation(value : Number) : void
		{
			value = SMathUtil.normalizeAngle(value);

			if (mRotation != value)
			{
				mRotation = value;
				mOrientationChanged = true;
			}
		}

		public function get width() : Number
		{
			return 0
		}

		public function set width(value : Number) : void
		{
		}

		public function get height() : Number
		{
			return 0
		}

		public function set height(value : Number) : void
		{
		}

		public function get alpha() : Number
		{
			return mAlpha;
		}

		public function set alpha(value : Number) : void
		{
			mAlpha = value < 0.0 ? 0.0 : (value > 1.0 ? 1.0 : value);
		}

		public function get visible() : Boolean
		{
			return mVisible;
		}

		public function set visible(value : Boolean) : void
		{
			mVisible = value;
		}

		public function get touchable() : Boolean
		{
			return mTouchable;
		}

		public function set touchable(value : Boolean) : void
		{
			mTouchable = value;
		}

		public function get blendMode() : String
		{
			return mBlendMode;
		}

		public function set blendMode(value : String) : void
		{
			mBlendMode = value;
		}

		public function get name() : String
		{
			return mName;
		}

		public function set name(value : String) : void
		{
			mName = value;
		}

		public function dispose() : void
		{
			removeFromParent();
			mParent = null;
		}
	}
}