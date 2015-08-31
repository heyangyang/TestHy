package hy.game.render
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;

	import hy.game.core.interfaces.IContainer;
	import hy.game.core.interfaces.IDisplay;

	public class SRenderContainer extends Sprite implements IContainer
	{
		protected var mRenders : Vector.<SRender>;
		protected var mNumRender : int;
		protected var mTag : String;
		protected var mPriority : int;

		public function SRenderContainer()
		{
			mRenders = new Vector.<SRender>();
			mNumRender = 0;
		}

		public function set tag(value : String) : void
		{
			mTag = value;
		}

		public function get tag() : String
		{
			return mTag;
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
		 * 每帧调用一次 
		 * 
		 */
		public function update() : void
		{
			
		}

		/**
		 * 添加显示对象,并且开启深度排序
		 * @param render
		 *
		 */
		public function push(render : SRender) : void
		{
			if (mRenders.indexOf(render) != -1)
				return;
			mRenders.push(render);
			addGameChild(render.display);
			render.index = mNumRender++;
			render.container = this;
		}

		/**
		 * 移除显示对象
		 * @param render
		 *
		 */
		public function remove(render : SRender) : void
		{
			var index : int = mRenders.indexOf(render);
			if (index == -1)
				return;
			mRenders.splice(index, 1);
			removeGameChild(render.display);
			mNumRender--;
			render.container = null;
		}

		/**
		 * 深度排序
		 *
		 */
		private var render_index : int;
		private var mChild : SRender;

		protected function updateDepthSort() : void
		{
//			mRenders.sort(sortDepthHandler);
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
		protected function updateChildIndex(render : SRender) : void
		{
			render.index = render_index;
			if (getGameChildIndex(render.display) != render_index)
				setGameChildIndex(render.display, render_index++);
			else
				render_index += 1;
			for (var i : int = 0; i < render.numChildren; i++)
			{
				mChild = render.getChildAt(i) as SRender;
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
//		private function sortDepthHandler(a : SRender, b : SRender) : Number
//		{
//			if (a.zDepth < b.zDepth)
//				return -1;
//			if (a.zDepth > b.zDepth)
//				return 1;
//			if (a.mId > b.mId)
//				return 1;
//			return -1;
//		}

		public function addGameChildAt(child : IDisplay, index : int) : void
		{
			if (child is DisplayObject)
			{
				addChildAt(child as DisplayObject, index);
			}
		}

		public function addGameChild(child : IDisplay) : void
		{
			if (child is DisplayObject)
			{
				addChild(child as DisplayObject);
			}
		}

		public function removeGameChildAt(index : int) : void
		{
			this.removeChildAt(index);
		}

		public function getGameChildIndex(child : IDisplay) : int
		{
			return this.getChildIndex(child as DisplayObject);
		}

		public function setGameChildIndex(child : IDisplay, index : int) : void
		{
			this.setChildIndex(child as DisplayObject, index);
		}

		public function removeGameChild(child : IDisplay) : void
		{
			this.removeChild(child as DisplayObject);
		}
	}
}