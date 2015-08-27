package hy.game.core
{
	import hy.game.core.interfaces.IContainer;
	import hy.game.core.interfaces.IGameContainer;
	import hy.game.core.interfaces.IRender;
	import hy.game.namespaces.name_part;
	import hy.game.render.SRender;

	use namespace name_part;

	public class GameContainer implements IGameContainer
	{
		private var m_tag : String;
		private var m_priority : int;
		protected var m_depthSort : Boolean;
		protected var m_prioritySort : Boolean;
		protected var m_objects : Vector.<GameObject>;
		protected var m_renders : Vector.<IRender>;
		protected var m_numRender : int;
		protected var m_container : IContainer;

		public function GameContainer(container : IContainer)
		{
			super();
			m_objects = new Vector.<GameObject>();
			m_renders = new Vector.<IRender>();
			m_numRender = 0;
			m_container = container;
		}

		/**
		 * 直接把渲染对象添加到显示列表，不加入队列
		 * @param render
		 * @param index
		 *
		 */
		public function addChildRender(render : IRender, index : int) : void
		{
			if (index > m_container.numChildren)
				index = m_container.numChildren;
			m_container.addGameChildAt(render.render, index);
		}

		/**
		 * 获得渲染对象索引
		 * @param render
		 * @return
		 *
		 */
		public function getRenderIndex(render : IRender) : int
		{
			return m_container.getGameChildIndex(render.render);
		}

		public function setChildRenderIndex(render : IRender, index : int) : void
		{
			if (getRenderIndex(render) == index)
				return;
			m_container.setGameChildIndex(render.render, index);
		}

		/**
		 * 添加显示对象,并且开启深度排序
		 * @param render
		 *
		 */
		public function addRender(render : IRender) : void
		{
			if (m_renders.indexOf(render) != -1)
				return;
			m_renders.push(render);
			m_container.addGameChild(render.render);
			render.index = m_numRender++;
			render.container = this;
			m_depthSort = true;
		}

		/**
		 * 移除显示对象
		 * @param render
		 *
		 */
		public function removeRender(render : IRender) : void
		{
			var index : int = m_renders.indexOf(render);
			if (index == -1)
				return;
			m_renders.splice(index, 1);
			m_container.removeGameChild(render.render);
			m_numRender--;
			render.container = null;
		}

		/**
		 * 添加游戏对象，并且进行优先级别排序
		 * @param object
		 *
		 */
		public function addObject(object : GameObject) : void
		{
			if (m_objects.indexOf(object) != -1)
				return;
			object.owner = this;
			m_objects.push(object);
			m_prioritySort = true;
		}

		/**
		 * 移除游戏对象
		 * @param object
		 *
		 */
		public function removeObject(object : GameObject) : void
		{
			var index : int = m_objects.indexOf(object);
			if (index == -1)
				return;
			object.owner = null;
			m_objects.splice(index, 1);
		}

		/**
		 * 设置排序状态
		 *
		 */
		public function changePrioritySort() : void
		{
			m_prioritySort = true;
		}

		/**
		 * 组件优先级别排序
		 *
		 */
		protected function onUpdateSort() : void
		{
			m_objects.sort(onPrioritySortFun);
			m_prioritySort = false;
		}

		private function onPrioritySortFun(a : GameObject, b : GameObject) : int
		{
			if (a.priority > b.priority)
				return 1;
			if (a.priority < b.priority)
				return -1;
			return 0;
		}

		/**
		 * 标记需要深度排序
		 *
		 */
		public function changeDepthSort() : void
		{
			m_depthSort = true;
		}

		public function set tag(value : String) : void
		{
			m_tag = value;
		}

		public function set priority(value : int) : void
		{
			m_priority = value;
		}

		public function get priority() : int
		{
			return m_priority;
		}
		/**
		 * 深度排序
		 *
		 */
		private var render_index : int;
		private var m_child : IRender;

		protected function updateDepthSort() : void
		{
			m_depthSort = false;
			m_renders.sort(sortDepthHandler);
			render_index = 0;
			for (var i : int = 0; i < m_numRender; i++)
			{
				m_child = m_renders[i];
				updateChildIndex(m_child);
			}
		}

		/**
		 * 如果有层级变化，则便利所有子对象，进行排序
		 * 没有层级 变化，则只加索引
		 * @param render
		 *
		 */
		protected function updateChildIndex(render : IRender) : void
		{
			render.index = render_index;
			if (m_container.getGameChildIndex(render.render) != render_index)
				m_container.setGameChildIndex(render.render, render_index++);
			else
				render_index += 1;
			for (var i : int = 0; i < render.numChildren; i++)
			{
				m_child = render.getChildAt(i);
				updateChildIndex(m_child);
			}
		}

		/**
		 *
		 * @param a
		 * @param b
		 * @return
		 *
		 */
		private function sortDepthHandler(a : SRender, b : SRender) : Number
		{
			if (a.zDepth < b.zDepth)
				return -1;
			if (a.zDepth > b.zDepth)
				return 1;
			if (a.mId > b.mId)
				return 1;
			return -1;
		}

		public function update() : void
		{
			m_prioritySort && onUpdateSort();
			var object : GameObject;
			for (var i : int = m_objects.length - 1; i >= 0; i--)
			{
				object = m_objects[i];
				if (object.isDestroy || !object.activeStatus || !object.checkUpdatable())
					continue;
				object.update();
			}
			m_depthSort && updateDepthSort();
		}

		public function get container() : IContainer
		{
			return m_container;
		}
	}
}