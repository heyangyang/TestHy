package hy.game.stage3D
{
	import flash.geom.Matrix;

	import hy.game.core.event.SEventDispatcher;
	import hy.game.stage3D.errors.AbstractMethodError;
	import hy.game.stage3D.utils.SMathUtil;



	public class SDisplayObject extends SEventDispatcher
	{
		private var mX : Number;
		private var mY : Number;
		private var mPivotX : Number;
		private var mPivotY : Number;
		private var mScaleX : Number;
		private var mScaleY : Number;
		private var mRotation : Number;
		private var mAlpha : Number;
		private var mVisible : Boolean;
		private var mTouchable : Boolean;
		private var mBlendMode : String;
		private var mName : String;
		private var mParent : SDisplayObjectContainer;
		private var mTransformationMatrix : Matrix;
		private var mOrientationChanged : Boolean;

		public function SDisplayObject()
		{
			super();
			mX = mY = mPivotX = mPivotY = mRotation = 0.0;
			mScaleX = mScaleY = mAlpha = 1.0;
			mVisible = mTouchable = true;
			mBlendMode = SBlendMode.AUTO;
			mTransformationMatrix = new Matrix();
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
		
		public function removeFromParent(dispose:Boolean=false):void
		{
			if (mParent) mParent.removeChild(this, dispose);
			else if (dispose) this.dispose();
		}

		public function setParent(value : SDisplayObjectContainer) : void
		{
			mParent = value;
		}

		public function get parent() : SDisplayObjectContainer
		{
			return mParent;
		}

		public function get transformationMatrix() : Matrix
		{
			if (!mOrientationChanged)
				return mTransformationMatrix;
			mOrientationChanged = false;

			if (mRotation == 0.0)
			{
				mTransformationMatrix.setTo(mScaleX, 0.0, 0.0, mScaleY, mX - mPivotX * mScaleX, mY - mPivotY * mScaleY);
			}
			else
			{
				var cos : Number = Math.cos(mRotation);
				var sin : Number = Math.sin(mRotation);
				var a : Number = mScaleX * cos;
				var b : Number = mScaleX * sin;
				var c : Number = mScaleY * -sin;
				var d : Number = mScaleY * cos;
				var tx : Number = mX - mPivotX * a - mPivotY * c;
				var ty : Number = mY - mPivotX * b - mPivotY * d;

				mTransformationMatrix.setTo(a, b, c, d, tx, ty);
			}

			return mTransformationMatrix;
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
				mOrientationChanged = true;
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
				mOrientationChanged = true;
			}
		}

		public function get pivotX() : Number
		{
			return mPivotX;
		}

		public function set pivotX(value : Number) : void
		{
			if (mPivotX != value)
			{
				mPivotX = value;
				mOrientationChanged = true;
			}
		}

		public function get pivotY() : Number
		{
			return mPivotY;
		}

		public function set pivotY(value : Number) : void
		{
			if (mPivotY != value)
			{
				mPivotY = value;
				mOrientationChanged = true;
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
		
		public function dispose():void
		{
			
		}
	}
}