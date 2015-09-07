package hy.game.render
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;

	import hy.game.interfaces.display.IDisplayContainer;
	import hy.game.interfaces.display.IDisplayObject;

	public class SRenderContainer extends Sprite implements IDisplayContainer
	{
		protected var mChildren : Vector.<IDisplayObject>;
		protected var mParent : IDisplayContainer;
		protected var mNumChildren : int;
		private var mLayer : int;

		public function SRenderContainer()
		{
			mChildren = new Vector.<IDisplayObject>();
			mNumChildren = 0;
		}

		/**
		 * 二分插入法
		 * @param child
		 *
		 */
		public function addDisplay(child : IDisplayObject) : void
		{
			child.setParent(this);
			if (mNumChildren == 0)
			{
				mChildren.push(child);
				addChild(child as DisplayObject);
				mNumChildren++;
				return;
			}
			var tIndex : int = mChildren.indexOf(child);
			//比较的索引
			var tSortIndex : int;
			//区间A，A-B,默认0开始
			var tStartSortIndex : int = 0;
			//区间B，A-B，默认数组长度
			var tEndSortIndex : int = mNumChildren - 1;
			//计算次数
			var tCount : int = 1;
			//每次计算后，区间值
			var tValue : int = tSortIndex = Math.ceil(mNumChildren - 1 >> tCount);
			while (tValue > 0)
			{
				tValue = Math.ceil(mNumChildren - 1 >> ++tCount);
				//如果是自己，则比较前后一个
				if (tSortIndex == tIndex)
				{
					if (child.layer > mChildren[tSortIndex + 1].layer)
						tSortIndex++;
					else
						tSortIndex--;
				}
				//向后查找
				if (child.layer > mChildren[tSortIndex].layer)
				{
					tStartSortIndex = tSortIndex;
					tSortIndex += tValue;
				}
				//向前查找
				else
				{
					tEndSortIndex = tSortIndex;
					tSortIndex -= tValue;
				}
			}
			for (tSortIndex = tStartSortIndex; tSortIndex <= tEndSortIndex; tSortIndex++)
			{
				if (child.layer < mChildren[tSortIndex].layer)
				{
					break;
				}
			}

			//移除以前的
			if (tIndex != -1)
				mChildren.splice(tIndex, 1);
			//新进来的则索引加1
			else
			{
				addChild(child as DisplayObject);
				mNumChildren++;
			}
			if (tIndex >= 0 && tIndex < tSortIndex)
				tSortIndex--;
			if (tSortIndex < 0)
				tSortIndex = 0;
			//插入
			mChildren.splice(tSortIndex, 0, child);
			setChildIndex(child as DisplayObject, tSortIndex);
		}

		public function removeDisplay(child : IDisplayObject, dispose : Boolean = false) : void
		{
			child.setParent(null);
			var index : int = mChildren.indexOf(child);
			if (index == -1)
				return;
			mChildren.splice(index, 1);
			removeChild(child as DisplayObject);
			mNumChildren--;
		}

		public function removeFromParent(dispose : Boolean = false) : void
		{
			if (mParent)
				mParent.removeDisplay(this, dispose);
			else if (dispose)
				this.dispose();
		}

		public function setParent(value : IDisplayContainer) : void
		{
			mParent = value;
		}

		public function get layer() : int
		{
			return mLayer;
		}

		public function set layer(value : int) : void
		{
			mLayer = value;
		}

		/**
		 * cpu渲染，方法暂时无用
		 *
		 */
		public function render() : void
		{

		}

		public function dispose() : void
		{
			removeFromParent();
			mParent = null;
			mChildren.length = 0;
			mNumChildren = 0;
		}

	}
}