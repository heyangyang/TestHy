package hy.game.data
{

	public class SPoint
	{
		private var m_x : int;
		private var m_y : int;

		public function SPoint(x : int = 0, y : int = 0)
		{
			m_x = x;
			m_y = y;
		}

		public function get x() : int
		{
			return m_x;
		}

		public function set x(value : int) : void
		{
			m_x = value;
		}

		public function get y() : int
		{
			return m_y;
		}

		public function set y(value : int) : void
		{
			m_y = value;
		}


	}
}