package hy.game.render
{
	import flash.geom.ColorTransform;

	import hy.game.core.interfaces.IBitmap;
	import hy.game.core.interfaces.IBitmapData;
	import hy.game.core.interfaces.IGameContainer;
	import hy.game.core.interfaces.IRecycle;
	import hy.game.core.interfaces.IRender;
	import hy.game.manager.SObjectManager;
	import hy.game.namespaces.name_part;

	use namespace name_part;

	/**
	 * 游戏显示对象
	 * @author hyy
	 *
	 */
	public class SRender implements IRender, IRecycle
	{
		protected var m_render : IBitmap;
		protected var m_bitmapData : IBitmapData;
		protected var m_name : String;
		name_part var m_parentX : int;
		name_part var m_parentY : int;
		protected var m_x : int=int.MIN_VALUE;
		protected var m_y : int=int.MIN_VALUE;
		protected var m_scaleX : Number;
		protected var m_scaleY : Number;
		protected var m_numChildren : int;
		protected var m_alpha : Number;
		protected var m_rotation : int;
		protected var m_zDepth : int;
		protected var m_index : int;
		protected var m_layer : int;
		protected var m_isSortLayer : Boolean;
		protected var m_visible : Boolean;
		protected var m_blendMode : String;
		protected var m_parent : IRender;
		protected var m_transform : ColorTransform
		protected var m_filters : Array;
		protected var m_childs : Vector.<IRender>;
		protected var m_tmpIndex : int;
		private var m_container : IGameContainer;

		public function SRender()
		{
			m_render = new SRenderBitmap();
		}

		public function notifyAddedToRender() : void
		{
			if (m_parent)
			{
				m_parentX = m_parent.x;
				m_parentY = m_parent.y;
				m_zDepth = m_parent.zDepth;
				var oldX : int = m_x;
				var oldY : int = m_y;
				m_x = m_y = int.MIN_VALUE;
				x = oldX;
				y = oldY;
			}
		}

		public function notifyRemovedFromRender() : void
		{
			m_render && m_render.removeChild();
			for (var i : int = 0; i < m_numChildren; i++)
			{
				m_childs[i].notifyRemovedFromRender();
			}
		}

		public function set container(value : IGameContainer) : void
		{
			m_container = value;
			if (!m_container)
				notifyRemovedFromRender();
		}

		/**
		 * 更新所有子元素层级
		 *
		 */
		private function updateIndex() : void
		{
			if (!m_container)
				return;
			m_tmpIndex = m_container.getRenderIndex(this);
			updateIndexByRender(this);
		}

		private function updateIndexByRender(render : SRender) : void
		{
			var child : SRender;
			for (var i : int = 0; i < m_numChildren; i++)
			{
				child = m_childs[i] as SRender;
				m_container.setChildRenderIndex(child, ++m_tmpIndex);
				child.numChildren > 0 && updateIndexByRender(child);
			}
		}

		public function addChild(child : IRender) : IRender
		{
			return addChildAt(child, m_numChildren);
		}

		public function addChildAt(child : IRender, index : int) : IRender
		{
			if (childs.indexOf(child) == -1)
			{
				m_container && m_container.addChildRender(child as SRender, getRenderIndex(child));
				m_numChildren++;
				childs.push(child);
				m_isSortLayer = true;
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
		private function getRenderIndex(child : IRender) : int
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

		public function removeChild(child : IRender) : IRender
		{
			return removeChildAt(childs.indexOf(child));
		}

		public function removeChildAt(index : int) : IRender
		{
			if (index < 0 || index >= m_numChildren)
				return null;
			m_numChildren--;
			var child : IRender = childs.splice(index, 1)[0];
			child.notifyRemovedFromRender();
			child.parent = null;
			return child;
		}

		public function getChildAt(index : int) : IRender
		{
			if (index < 0 || index >= m_numChildren)
				return null;
			return childs[index];
		}

		public function getChildIndex(child : IRender) : int
		{
			return childs.indexOf(child);
		}

		public function getChildByName(name : String) : IRender
		{
			var child : IRender;
			for (var i : int = 0; i < m_numChildren; i++)
			{
				child = childs[i];
				if (child.name == name)
					return child;
			}
			return null;
		}

		private function get childs() : Vector.<IRender>
		{
			if (m_childs == null)
				m_childs = new Vector.<IRender>();
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

		public function get parent() : IRender
		{
			return m_parent;
		}

		public function set parent(value : IRender) : void
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
			{
				m_render.x = m_x + m_parentX;
				updateChildByField("parentX", m_x);
			}
		}

		name_part function set parentX(value : Number) : void
		{
			if (m_parentX == value)
				return;
			m_parentX = value;
			if (m_render)
				m_render.x = m_x + m_parentX;
		}

		name_part function set parentY(value : Number) : void
		{
			if (m_parentY == value)
				return;
			m_parentY = value;
			if (m_render)
				m_render.y = m_y + m_parentY;
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
			{
				m_render.y = m_y + m_parentY;
				updateChildByField("parentY", m_y);
			}
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

		public function get scaleX() : Number
		{
			return m_scaleX;
		}

		public function set scaleX(value : Number) : void
		{
			if (m_scaleX == value)
				return;
			m_scaleX = value;
			if (m_render)
				m_render.scaleX = m_scaleX;
		}

		public function get scaleY() : Number
		{
			return m_scaleY;
		}

		public function set scaleY(value : Number) : void
		{
			if (m_scaleY == value)
				return;
			m_scaleY = value;
			if (m_render)
				m_render.scaleY = m_scaleY;
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
			m_container && m_container.changeDepthSort();
		}

		public function get index() : int
		{
			return m_index;
		}

		public function set index(value : int) : void
		{
			m_index = value;
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
			if (m_parent)
				m_parent.needLayerSort = true;
		}

		public function get needLayerSort() : Boolean
		{
			return m_isSortLayer;
		}

		public function set needLayerSort(value : Boolean) : void
		{
			m_isSortLayer = true;
		}

		public function onLayerSort() : void
		{
			m_childs.sort(onSortLayer);
			updateIndex();
			m_isSortLayer = false;
		}

		private function onSortLayer(a : SRender, b : SRender) : int
		{
			if (a.layer > b.layer)
				return 1;
			if (a.layer < b.layer)
				return -1;
			return 0;
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

		public function set bitmapData(value : IBitmapData) : void
		{
			if (m_bitmapData == value)
				return;
			m_bitmapData = value;
			render.data = value;
		}

		public function get bitmapData() : IBitmapData
		{
			return render.data;
		}

		private function updateChildByField(field : String, value : *) : void
		{
			for (var i : int = 0; i < m_numChildren; i++)
			{
				m_childs[i][field] = value;
			}
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
			if (parent)
			{
				parent.removeChild(this);
				parent = null;
			}
			while (m_numChildren > 0)
				removeChildAt(0);
			bitmapData = null;
			m_numChildren = 0;
		}
	}
}