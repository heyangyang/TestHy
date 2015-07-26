package hy.game.render
{
	import flash.geom.ColorTransform;
	
	import hy.game.core.interfaces.IBitmap;
	import hy.game.core.interfaces.IGameContainer;
	import hy.game.core.interfaces.IGameRender;
	import hy.game.core.interfaces.IRecycle;
	import hy.game.manager.SObjectManager;
	import hy.game.namespaces.name_part;

	use namespace name_part;

	/**
	 * 游戏显示对象 
	 * @author hyy
	 * 
	 */
	public class SGameRender implements IGameRender, IRecycle
	{
		protected var m_render : IBitmap;
		protected var m_name : String;
		name_part var m_parentX : int;
		name_part var m_parentY : int;
		protected var m_x : int;
		protected var m_y : int;
		protected var m_scale : int;
		protected var m_numChildren : int;
		protected var m_alpha : int;
		protected var m_rotation : int;
		protected var m_zDepth : int;
		protected var m_layer : int;
		protected var m_visible : Boolean;
		protected var m_blendMode : String;
		protected var m_parent : IGameRender;
		protected var m_transform : ColorTransform
		protected var m_filters : Array;
		protected var m_childs : Vector.<IGameRender>;
		private var m_container : IGameContainer;

		public function SGameRender()
		{
			m_render = new SRenderBitmap();
		}

		public function notifyAddedToRender() : void
		{
			if (m_parent)
			{
				m_parentX = m_parent.x;
				m_parentY = m_parent.y;
				depth = m_parent.zDepth;
				x = m_x;
				y = m_y;
			}
		}

		public function notifyRemovedFromRender() : void
		{
			m_render && m_render.removeChild();
		}

		public function set container(value : IGameContainer) : void
		{
			m_container = value;
			if (m_childs && m_container)
			{
				var child : SGameRender;
				for (var i : int = 0; i < m_numChildren; i++)
				{
					child = m_childs[i] as SGameRender;
					m_container.addChildRender(child, getRenderIndex(child));
				}
			}
		}

		public function addChild(child : IGameRender) : IGameRender
		{
			return addChildAt(child, m_numChildren);
		}

		public function addChildAt(child : IGameRender, index : int) : IGameRender
		{
			if (childs.indexOf(child) == -1)
			{
				m_container && m_container.addChildRender(child as SGameRender, getRenderIndex(child));
				m_numChildren++;
				childs.splice(index, 0, child);
				child.parent = this;
				child.notifyAddedToRender();
			}
			return child;
		}

		/**
		 * 根据layer获取添加到容器里面的索引
		 * @param child
		 * @return
		 *
		 */
		private function getRenderIndex(child : IGameRender) : int
		{
			//父类所在容器的索引
			var index : int = m_container.getRenderIndex(this) + 1;
			for (var i : int = 0; i < m_numChildren; i++)
			{
				if (child.layer >= m_childs[i].layer)
					index++;
			}
			return index;
		}

		public function removeChild(child : IGameRender) : IGameRender
		{
			return removeChildAt(childs.indexOf(child));
		}

		public function removeChildAt(index : int) : IGameRender
		{
			if (index < 0 || index >= m_numChildren)
				return null;
			m_numChildren--;
			var child : IGameRender = childs.splice(index, 1) as IGameRender
			child.notifyRemovedFromRender();
			child.parent = null;
			return child;
		}

		public function getChildAt(index : int) : IGameRender
		{
			if (index < 0 || index >= m_numChildren)
				return null;
			return childs[index];
		}

		public function getChildIndex(child : IGameRender) : int
		{
			return childs.indexOf(child);
		}

		public function getChildByName(name : String) : IGameRender
		{
			var child : IGameRender;
			for (var i : int = 0; i < m_numChildren; i++)
			{
				child = childs[i];
				if (child.name == name)
					return child;
			}
			return null;
		}

		private function get childs() : Vector.<IGameRender>
		{
			if (m_childs == null)
				m_childs = new Vector.<IGameRender>();
			return m_childs;
		}

		public function removeAllChildren() : void
		{
			while (m_numChildren > 0)
			{
				removeChildAt(m_numChildren - 1);
			}
		}

		public function get numChildren() : int
		{
			return m_numChildren;
		}

		public function get parent() : IGameRender
		{
			return m_parent;
		}

		public function set parent(value : IGameRender) : void
		{
			if (m_parent == value)
				return;
			m_parent = value;
		}

		public function rotate(rotate : Number) : void
		{
		}

		public function get x() : Number
		{
			return m_x;
		}

		public function set x(value : Number) : void
		{
			if (m_x == value)
				return;
			m_x = value;
			if (m_render)
				m_render.x = m_x + m_parentX;
		}

		public function get y() : Number
		{
			return m_y;
		}

		public function set y(value : Number) : void
		{
			if (m_y == value)
				return;
			m_y = value;

			if (m_render)
				m_render.y = m_y + m_parentY;
		}

		public function get width() : Number
		{
			if (!m_render)
				return 0;
			return m_render.width;
		}

		public function get height() : Number
		{
			if (!m_render)
				return 0;
			return m_render.height;
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
			if (m_render)
				m_render.scaleX = m_render.scaleY = m_scale;
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
			if (m_render)
				m_render.alpha = m_alpha;
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
			if (m_render)
				m_render.filters = m_filters;
		}

		public function get rotation() : Number
		{
			return m_rotation;
		}

		public function set rotation(value : Number) : void
		{
			if (m_rotation == value)
				return;
			m_rotation = value;
			if (m_render)
				m_render.rotation = m_rotation;
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
			if (m_render)
				m_render.blendMode = m_blendMode;
		}

		public function get colorTransform() : ColorTransform
		{
			return m_transform;
		}

		public function set colorTransform(value : ColorTransform) : void
		{
			if (m_transform == value)
				return;
			m_transform = value;
			if (m_render)
				m_render.colorTransform = m_transform;
		}

		public function get visible() : Boolean
		{
			return m_visible;
		}

		public function set visible(value : Boolean) : void
		{
			if (m_visible == value)
				return;
			m_visible = value;
			if (m_render)
				m_render.visible = m_visible;
		}

		/**
		 * 深度 （只读）
		 * @param value
		 *
		 */
		public function get zDepth() : int
		{
			return m_zDepth;
		}

		/**
		 * 设置深度，用于深度排序
		 * @param value
		 *
		 */
		name_part function set depth(value : int) : void
		{
			m_zDepth = value;
		}

		/**
		 * 层级
		 * @return
		 *
		 */
		public function get layer() : int
		{
			return m_layer;
		}

		public function set layer(value : int) : void
		{
			m_layer = value;
		}

		public function get name() : String
		{
			return m_name;
		}

		public function set name(value : String) : void
		{
			m_name = value;
		}

		public function get render() : IBitmap
		{
			return m_render;
		}

		/**
		 * 回收
		 *
		 */
		public function recycle() : void
		{
			SObjectManager.recycleObject(this);
		}

		public function dispose() : void
		{
			if (m_childs)
				m_childs.length = 0;
			if (parent)
			{
				parent.removeChild(this);
				parent = null;
			}
			m_numChildren = 0;
			if (m_render)
				m_render.data = null;
		}
	}
}