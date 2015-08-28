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
		private var mTag : String;
		private var mPriority : int;
		protected var mDepthSort : Boolean;
		protected var mPrioritySort : Boolean;
		protected var mObjects : Vector.<GameObject>;
		protected var mRenders : Vector.<IRender>;
		protected var mNumRender : int;
		protected var mContainer : IContainer;

		public function GameContainer(container : IContainer)
		{
			super();
			mObjects = new Vector.<GameObject>();
			mRenders = new Vector.<IRender>();
			mNumRender = 0;
			mContainer = container;
		}

		/**
		 * 直接把渲染对象添加到显示列表，不加入队列
		 * @param render
		 * @param index
		 *
		 */
		public function addChildRender(render : IRender, index : int) : void
		{
			if (index > mContainer.numChildren)
				index = mContainer.numChildren;
			mContainer.addGameChildAt(render.render, index);
		}

		/**
		 * 获得渲染对象索引
		 * @param render
		 * @return
		 *
		 */
		public function getRenderIndex(render : IRender) : int
		{
			return mContainer.getGameChildIndex(render.render);
		}

		public function setChildRenderIndex(render : IRender, index : int) : void
		{
			if (getRenderIndex(render) == index)
				return;
			mContainer.setGameChildIndex(render.render, index);
		}

		/**
		 * 添加显示对象,并且开启深度排序
		 * @param render
		 *
		 */
		public function addRender(render : IRender) : void
		{
			if (mRenders.indexOf(render) != -1)
				return;
			mRenders.push(render);
			mContainer.addGameChild(render.render);
			render.index = mNumRender++;
			render.container = this;
			mDepthSort = true;
		}

		/**
		 * 移除显示对象
		 * @param render
		 *
		 */
		public function removeRender(render : IRender) : void
		{
			var index : int = mRenders.indexOf(render);
			if (index == -1)
				return;
			mRenders.splice(index, 1);
			mContainer.removeGameChild(render.render);
			mNumRender--;
			render.container = null;
		}

		/**
		 * 添加游戏对象，并且进行优先级别排序
		 * @param object
		 *
		 */
		public function addObject(object : GameObject) : void
		{
			if (mObjects.indexOf(object) != -1)
				return;
			object.owner = this;
			mObjects.push(object);
			mPrioritySort = true;
		}

		/**
		 * 移除游戏对象
		 * @param object
		 *
		 */
		public function removeObject(object : GameObject) : void
		{
			var index : int = mObjects.indexOf(object);
			if (index == -1)
				return;
			object.owner = null;
			mObjects.splice(index, 1);
		}

		/**
		 * 设置排序状态
		 *
		 */
		public function changePrioritySort() : void
		{
			mPrioritySort = true;
		}

		/**
		 * 组件优先级别排序
		 *
		 */
		protected function onUpdateSort() : void
		{
			mObjects.sort(onPrioritySortFun);
			mPrioritySort = false;
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
			mDepthSort = true;
		}

		public function set tag(value : String) : void
		{
			mTag = value;
		}

		public function set priority(value : int) : void
		{
			mPriority = value;
		}

		public function get priority() : int
		{
			return mPriority;
		}
		/**
		 * 深度排序
		 *
		 */
		private var render_index : int;
		private var mChild : IRender;

		protected function updateDepthSort() : void
		{
			mDepthSort = false;
			mRenders.sort(sortDepthHandler);
			render_index = 0;
			for (var i : int = 0; i < mNumRender; i++)
			{
				mChild = mRenders[i];
				updateChildIndex(mChild);
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
			if (mContainer.getGameChildIndex(render.render) != render_index)
				mContainer.setGameChildIndex(render.render, render_index++);
			else
				render_index += 1;
			for (var i : int = 0; i < render.numChildren; i++)
			{
				mChild = render.getChildAt(i);
				updateChildIndex(mChild);
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
			mPrioritySort && onUpdateSort();
			var object : GameObject;
			for (var i : int = mObjects.length - 1; i >= 0; i--)
			{
				object = mObjects[i];
				if (object.isDispose || !object.activeStatus || !object.checkUpdatable())
					continue;
				object.update();
			}
			mDepthSort && updateDepthSort();
		}

		public function get container() : IContainer
		{
			return mContainer;
		}
	}
}