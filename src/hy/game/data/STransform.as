package hy.game.data
{
	import flash.geom.ColorTransform;

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

		private var m_x : int;
		private var m_y : int;
		private var m_z : int;
		private var m_centerOffsetY : int;

		private var m_scale : Number;

		private var m_alpha : Number;

		private var m_filters : Array;

		private var m_transform : ColorTransform;

		private var m_blendMode : String;

		private var m_width : int;
		private var m_height : int;

		private var m_change : int;

		public var dir : int;

		private var m_rectangle : SRectangle;

		name_part var mx : int;
		name_part var my : int;

		public var isMouseOver : Boolean;

		public function STransform()
		{
			m_rectangle = new SRectangle();
		}

		public function get rectangle() : SRectangle
		{
			return m_rectangle;
		}

		public function get x() : int
		{
			return m_x;
		}

		public function set x(value : int) : void
		{
			if (m_x == value)
				return;
			if (value < 0)
				value = 0;
			m_x = value;
			if ((m_change & C_XYZ) == 0)
				m_change += C_XYZ;
		}

		public function get y() : int
		{
			return m_y;
		}

		public function set y(value : int) : void
		{
			if (m_y == value)
				return;
			if (value < 0)
				value = 0;
			m_y = value;
			if ((m_change & C_XYZ) == 0)
				m_change += C_XYZ;
		}

		public function get z() : int
		{
			return m_z;
		}

		public function set z(value : int) : void
		{
			if (m_z == value)
				return;
			m_z = value;
			if ((m_change & C_XYZ) == 0)
				m_change += C_XYZ;
		}

		public function get centerOffsetY() : int
		{
			return m_centerOffsetY;
		}

		public function set centerOffsetY(value : int) : void
		{
			if (m_centerOffsetY == value)
				return;
			m_centerOffsetY = value;
			if ((m_change & C_XYZ) == 0)
				m_change += C_XYZ;
		}

		public function get scale() : Number
		{
			return m_scale;
		}

		public function set scale(value : Number) : void
		{
			if (m_scale == value)
				return;
			m_scale = value;
		}

		public function get alpha() : Number
		{
			return m_alpha;
		}

		public function set alpha(value : Number) : void
		{
			if (m_alpha == value)
				return;
			m_alpha = value;
			if ((m_change & C_ALPHA) == 0)
				m_change += C_ALPHA;
		}

		public function get filters() : Array
		{
			return m_filters;
		}

		public function set filters(value : Array) : void
		{
			if (m_filters == value)
				return;
			m_filters = value;
		}

		public function get transform() : ColorTransform
		{
			return m_transform;
		}

		public function set transform(value : ColorTransform) : void
		{
			if (m_transform == value)
				return;
			m_transform = value;
		}

		public function get blendMode() : String
		{
			return m_blendMode;
		}

		public function set blendMode(value : String) : void
		{
			if (m_blendMode == value)
				return;
			m_blendMode = value;
		}

		public function isChangeFiled(key : int) : Boolean
		{
			return (m_change & key) != 0;
		}

		public function set width(value : int) : void
		{
			if (m_width == value)
				return;
			m_width = value;
			if ((m_change & C_WH) == 0)
				m_change += C_WH;
		}

		public function get width() : int
		{
			return m_width;
		}

		public function set height(value : int) : void
		{
			if (m_height == value)
				return;
			m_height = value;
			if ((m_change & C_WH) == 0)
				m_change += C_WH;
		}

		public function get height() : int
		{
			return m_height;
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
			if (x < m_x + m_rectangle.x || x > m_x + m_rectangle.right)
				return false;
			if (y < m_y + m_rectangle.y || y > m_y + m_rectangle.bottom)
				return false;
			return true;
		}

		public function updateRender(render : IRender) : void
		{
			if (isChangeFiled(C_XYZ))
			{
				render.x = m_x;
				render.y = m_y;
			}
			if (isChangeFiled(C_ALPHA))
				render.alpha = m_alpha;
		}

		name_part function changAll() : void
		{
			m_change = 0;
			m_change += C_XYZ;
			m_change += C_WH;
			m_change += C_ALPHA;
		}

		/**
		 * 改变后清零
		 *
		 */
		name_part function hasChanged() : void
		{
			m_change = 0;
		}
	}
}