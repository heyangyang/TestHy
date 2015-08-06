package hy.game.data
{

	/**
	 * 一个矩阵
	 * @author hyy
	 *
	 */
	public class SRectangle extends SObject
	{
		private var m_x : int;
		private var m_y : int;
		private var m_w : int;
		private var m_h : int;
		private var m_bottom : int;
		private var m_right : int;

		public function SRectangle()
		{
			super();
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
			m_x = x;
			m_y = y;
			m_w = w;
			m_h = h;
			m_right = x + w;
			m_bottom = y + h;
		}

		public function contains(rect : SRectangle) : void
		{
			x = Math.min(m_x, rect.x);
			y = Math.min(m_x, rect.y);
			right = Math.max(m_right, rect.right);
			bottom = Math.max(m_bottom, rect.bottom);
		}

		public function containsByPoint(px : int, py : int) : Boolean
		{
			if (px >= m_x && px <= m_right && py >= m_y && py <= m_bottom)
				return true;
			return false;
		}

		public function setEmpty() : void
		{
			updateRectangle(0, 0, 0, 0);
		}

		public function get x() : int
		{
			return m_x;
		}

		public function set x(value : int) : void
		{
			m_x = value;
			m_right = m_x + m_w;
		}

		public function get y() : int
		{
			return m_y;
		}

		public function set y(value : int) : void
		{
			m_y = value;
			m_bottom = m_y + m_h;
		}

		public function get width() : int
		{
			return m_w;
		}

		public function set width(value : int) : void
		{
			m_w = value;
			m_right = m_x + m_w;
		}

		public function get height() : int
		{
			return m_h;
		}

		public function set height(value : int) : void
		{
			m_h = value;
			m_bottom = m_y + m_h;
		}

		/**
		 * x+w的组合,方块最远x坐标点
		 * @return
		 *
		 */
		public function get right() : int
		{
			return m_right;
		}

		public function set right(value : int) : void
		{
			m_right = value;
			m_w = m_right - m_x;
		}

		/**
		 *  y+h的组合,方块最远y坐标点
		 * @return
		 *
		 */
		public function get bottom() : int
		{
			return m_bottom;
		}

		public function set bottom(value : int) : void
		{
			m_bottom = value;
			m_h = m_bottom - m_y;
		}

	}
}