package hy.game.data
{

	public class SPoint
	{
		private var mX : int;
		private var mY : int;

		public function SPoint(x : int = 0, y : int = 0)
		{
			mX = x;
			mY = y;
		}

		public function get x() : int
		{
			return mX;
		}

		public function set x(value : int) : void
		{
			mX = value;
		}

		public function get y() : int
		{
			return mY;
		}

		public function set y(value : int) : void
		{
			mY = value;
		}


	}
}