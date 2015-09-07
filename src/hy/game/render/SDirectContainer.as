package hy.game.render
{
	import hy.game.interfaces.display.IDisplayContainer;
	import hy.game.interfaces.display.IDisplayObject;
	import hy.game.namespaces.name_part;
	import hy.game.stage3D.display.SDisplayObject;

	use namespace name_part;

	public class SDirectContainer extends SDisplayObject implements IDisplayContainer
	{
		private var mChildren : Vector.<SDisplayObject>;
		private var mNumChildren : int;
		private var mFilters : Array;

		public function SDirectContainer()
		{
			super();
			mChildren = new Vector.<SDisplayObject>();
			mNumChildren = 0;
		}

		/**
		 * 二分插入法
		 * @param child
		 *
		 */
		public function addDisplay(child : IDisplayObject) : void
		{
			if (mNumChildren == 0)
			{
				mChildren.push(child);
				mNumChildren++;
				child.setParent(this);
				return;
			}
			var tIndex : int = mChildren.indexOf(child as SDisplayObject);
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
				child.setParent(this);
				mNumChildren++;
			}
			if (tIndex >= 0 && tIndex < tSortIndex)
				tSortIndex--;
			if (tSortIndex < 0)
				tSortIndex = 0;
			//插入
			mChildren.splice(tSortIndex, 0, child);
		}

		public function removeDisplay(child : IDisplayObject, dispose : Boolean = false) : void
		{
			var index : int = mChildren.indexOf(child as SDisplayObject);
			if (index == -1)
				return;
			child.setParent(null);
			mChildren.splice(index, 1);
			mNumChildren--;
		}

		public override function render() : void
		{
			var child : SDisplayObject;
			for (var i : int = 0; i < mNumChildren; ++i)
			{
				child = mChildren[i];
				//父类的坐标。透明度
				child.mParentX = mParentX + mX;
				child.mParentY = mParentY + mY;
				child.mParentAlpha = mParentAlpha * mAlpha;
				child.render();
			}
		}

		public function get filters() : Array
		{
			return mFilters;
		}

		public function set filters(value : Array) : void
		{
			if (mFilters == value)
				return;
			mFilters = value;
		}

		/**
		 * 容器暂不能旋转 
		 * @param value
		 * 
		 */
		public override function set rotation(value : Number) : void
		{
			
		}
		
		/**
		 * 容器暂不能缩放 
		 * @param value
		 * 
		 */
		public override function set scaleX(value:Number):void
		{
			
		}
		
		/**
		 * 容器暂不能缩放 
		 * @param value
		 * 
		 */
		public override function set scaleY(value:Number):void
		{
			
		}
		
		public override function dispose() : void
		{
			super.dispose();
			mChildren.length = 0;
			mNumChildren = 0;
			mFilters = null;
		}
	}
}