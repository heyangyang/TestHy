package hy.game.data
{
	import flash.geom.Transform;
	
	import hy.game.namespaces.name_part;

	/**
	 * 游戏中显示对象的数据 
	 * @author hyy
	 * 
	 */
	public class STransform extends SObject
	{
		private var m_x : int;
		private var m_y : int;

		private var m_scale : Number;

		private var m_alpha : Number;

		private var m_filters : Array;

		private var m_transform : Transform;

		private var m_blendMode : String;

		private var m_width:int;
		private var m_height:int;
		
		private var m_isChange : Boolean;
		
		public var dir:int;

		public function STransform()
		{
		}

		public function get x() : int
		{
			return m_x;
		}

		public function set x(value : int) : void
		{
			if (m_x == value)
				return;
			m_x = value;
			m_isChange = true;
		}

		public function get y() : int
		{
			return m_y;
		}

		public function set y(value : int) : void
		{
			if (m_y == value)
				return;
			m_y = value;
			m_isChange = true;
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
			m_isChange = true;
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
			m_isChange = true;
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
			m_isChange = true;
		}

		public function get transform() : Transform
		{
			return m_transform;
		}

		public function set transform(value : Transform) : void
		{
			if (m_transform == value)
				return;
			m_transform = value;
			m_isChange = true;
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
			m_isChange = true;
		}

		public function get isChange() : Boolean
		{
			return m_isChange;
		}

		public function set width(value : int) : void
		{
			m_width = value;
		}
		
		public function get width():int
		{
			return m_width;
		}
		
		public function set height(value : int) : void
		{
			m_height = value;
		}
		
		public function get height():int
		{
			return m_height;
		}
		
		name_part function update() : void
		{
			m_isChange = false;
		}
	}
}