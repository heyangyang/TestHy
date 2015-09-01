package hy.game.render
{
	import hy.game.interfaces.display.IDisplayBase;
	import hy.game.interfaces.display.IDisplayObject;
	import hy.game.interfaces.display.IDisplayRenderContainer;
	import hy.game.stage3D.display.SDisplayObjectContainer;

	public class SDirectContainer extends SDisplayObjectContainer implements IDisplayRenderContainer
	{

		public function SDirectContainer()
		{
			super();
		}

		/**
		 * 二分插入法
		 * @param child
		 *
		 */
		public function sort2Push(child : IDisplayBase) : void
		{
			if (mNumChildren == 0)
			{
				mChildren.push(child);
				mNumChildren++;
				return;
			}
			var tIndex : int = mChildren.indexOf(child as IDisplayObject);
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
				mNumChildren++;
			if (tIndex >= 0 && tIndex < tSortIndex)
				tSortIndex--;
			if (tSortIndex < 0)
				tSortIndex = 0;
			//插入
			mChildren.splice(tSortIndex, 0, child);
		}

		/**
		 * 移除显示对象
		 * @param render
		 *
		 */
		public function remove(render : SRender) : void
		{
			var index : int = mChildren.indexOf(render);
			if (index == -1)
				return;
			mChildren.splice(index, 1);
			mNumChildren--;
		}


	}
}