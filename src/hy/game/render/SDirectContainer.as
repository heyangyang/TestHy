package hy.game.render
{
	import hy.game.core.interfaces.IContainer;
	import hy.game.stage3D.display.SDisplayObjectContainer;

	public class SDirectContainer extends SDisplayObjectContainer implements IContainer
	{
		protected var mRenders : Vector.<SRender>;
		protected var mNumRender : int;
		protected var mTag : String;
		protected var mPriority : int;

		public function SDirectContainer()
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

		public override function render() : void
		{
			for (var i : int = 0; i < mNumRender; i++)
			{
				mRenders[i].render();
			}
		}

		/**
		 * 二分插入法
		 * @param child
		 *
		 */
		public function sort2Push(child : SRender) : void
		{
			if (mNumRender == 0)
			{
				mRenders.push(child);
				return;
			}
			var tIndex : int = mRenders.indexOf(child);
			//比较的索引
			var tSortIndex : int;
			//区间A，A-B,默认0开始
			var tStartSortIndex : int = 0;
			//区间B，A-B，默认数组长度
			var tEndSortIndex : int = mNumRender - 1;
			//计算次数
			var tCount : int = 1;
			//每次计算后，区间值
			var tValue : int = tSortIndex = Math.ceil(mNumRender - 1 >> tCount);
			while (tValue > 0)
			{
				tValue = Math.ceil(mNumRender - 1 >> ++tCount);
				//如果是自己，则比较前后一个
				if (tSortIndex == tIndex)
				{
					if (child.layer > mRenders[tSortIndex + 1].layer)
						tSortIndex++;
					else
						tSortIndex--;
				}
				//向后查找
				if (child.layer > mRenders[tSortIndex].layer)
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
				if (child.layer < mRenders[tSortIndex].layer)
				{
					break;
				}
			}

			var value : int = mRenders[0].layer;
			for (var i : int = 1; i < mNumRender; i++)
			{
				if (value > mRenders[i].layer)
					trace(1111);
				value = mRenders[i].layer;
			}
			//移除以前的
			if (tIndex != -1)
				mRenders.splice(tIndex, 1);
			//插入
			mRenders.splice(tIndex == -1 || tIndex > tSortIndex ? tSortIndex : tSortIndex + 1, 0, child);
		}

		/**
		 * 添加显示对象,并且开启深度排序
		 * @param render
		 *
		 */
		public function push(render : SRender) : void
		{
			if (mRenders.indexOf(render) != -1)
			{
				sort2Push(render);
				return;
			}
			sort2Push(render);
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
			mNumRender--;
			render.container = null;
		}


	}
}