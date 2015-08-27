package hy.game.data
{

	/**
	 * 一个矩阵
	 * @author hyy
	 *
	 */
	public class SRectangle extends SObject
	{
		private var mX : int;
		private var mY : int;
		private var mWidth : int;
		private var mHeight : int;
		private var mBottom : int;
		private var mRight : int;

		public function SRectangle(x : int = 0, y : int = 0, w : int = 0, h : int = 0)
		{
			updateRectangle(x, y, w, h);
		}

		/**
		 *  更新可视范围
		 * @param x
		 * @param y
		 * @param w
		 * @param h
		 *
		 */
		public function updateRectangle(x : int, y : int, w : int, h : int) : void
		{
			mX = x;
			mY = y;
			mWidth = w;
			mHeight = h;
			mRight = x + w;
			mBottom = y + h;
		}

		public function contains(rect : SRectangle) : void
		{
			x = Math.min(mX, rect.x);
			y = Math.min(mX, rect.y);
			right = Math.max(mRight, rect.right);
			bottom = Math.max(mBottom, rect.bottom);
		}

		public function containsByPoint(px : int, py : int) : Boolean
		{
			if (px >= mX && px <= mRight && py >= mY && py <= mBottom)
				return true;
			return false;
		}

		public function setEmpty() : void
		{
			updateRectangle(0, 0, 0, 0);
		}

		public function get x() : int
		{
			return mX;
		}

		public function set x(value : int) : void
		{
			mX = value;
			mRight = mX + mWidth;
		}

		public function get y() : int
		{
			return mY;
		}

		public function set y(value : int) : void
		{
			mY = value;
			mBottom = mY + mHeight;
		}

		public function get width() : int
		{
			return mWidth;
		}

		public function set width(value : int) : void
		{
			mWidth = value;
			mRight = mX + mWidth;
		}

		public function get height() : int
		{
			return mHeight;
		}

		public function set height(value : int) : void
		{
			mHeight = value;
			mBottom = mY + mHeight;
		}

		/**
		 * x+w的组合,方块最远x坐标点
		 * @return
		 *
		 */
		public function get right() : int
		{
			return mRight;
		}

		public function set right(value : int) : void
		{
			mRight = value;
			mWidth = mRight - mX;
		}

		/**
		 *  y+h的组合,方块最远y坐标点
		 * @return
		 *
		 */
		public function get bottom() : int
		{
			return mBottom;
		}

		public function set bottom(value : int) : void
		{
			mBottom = value;
			mHeight = mBottom - mY;
		}

		public function toString() : String
		{
			return "[ x : " + mX + " y : " + mY + " width : " + mWidth + " height : " + mHeight + "]";
		}

	}
}