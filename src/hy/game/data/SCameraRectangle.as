package hy.game.data
{

	/**
	 * 一个矩阵，用来设定相机内可以走动范围
	 * @author hyy
	 *
	 */
	public class SCameraRectangle extends SObject
	{
		private var m_x : int;
		private var m_y : int;
		private var m_w : int;
		private var m_h : int;

		public function SCameraRectangle()
		{
			super();
		}

		/**
		 * 更新可视范围
		 * @param x
		 * @param y
		 *
		 */
		public function updateRectangle(x : int, y : int, w : int, h : int) : void
		{
			m_x = x;
			m_y = y;
			m_w = w;
			m_h = h;
		}

		public function get x() : int
		{
			return m_x;
		}

		public function get y() : int
		{
			return m_y;
		}

		public function get width() : int
		{
			return m_w;
		}

		public function get height() : int
		{
			return m_h;
		}


	}
}