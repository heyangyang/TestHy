package hy.game.render
{
	import flash.geom.ColorTransform;

	import hy.game.cfg.Config;
	import hy.game.interfaces.core.IRecycle;
	import hy.game.interfaces.display.IBitmap;
	import hy.game.interfaces.display.IBitmapData;
	import hy.game.interfaces.display.IDisplayBase;
	import hy.game.interfaces.display.IDisplayObject;
	import hy.game.interfaces.display.IDisplayObjectContainer;
	import hy.game.interfaces.display.IDisplayRender;
	import hy.game.manager.SMemeryManager;
	import hy.game.namespaces.name_part;

	use namespace name_part;

	/**
	 * 游戏显示对象
	 * @author hyy
	 *
	 */
	public class SRender implements IDisplayRender, IRecycle
	{
		private static var sIds : uint = 1000;
		/**
		 * 唯一id
		 */
		name_part var mId : uint;
		private var mRender : IBitmap;
		private var mBitmapData : IBitmapData;
		private var mName : String;
		name_part var mParentX : int;
		name_part var mParentY : int;
		name_part var mParentAlpha : Number;
		private var mX : Number;
		private var mY : Number;
		private var mScaleX : Number;
		private var mScaleY : Number;
		private var mNumChildren : int;
		private var mAlpha : Number;
		private var mRotation : Number;
		/**
		 * 层级
		 */
		private var mLayer : int;
		/**
		 * 深度+层级+mId ，用于深度排序
		 * mId防止同一深度，层级混乱排序
		 */
		private var mIndex : int;
		/**
		 * 深度
		 */
		private var mDepth : int;
		private var mVisible : Boolean;
		private var mBlendMode : String;
		private var mParent : IDisplayRender;
		private var mTransform : ColorTransform
		private var mFilters : Array;
		private var mChilds : Vector.<IDisplayRender>;

		public function SRender()
		{
			mId = sIds++;
			mAlpha = mParentAlpha = 1.0;
			if (Config.supportDirectX)
				mRender = new SDirectBitmap();
			else
				mRender = new SRenderBitmap();
		}

		private function notifyAddedToRender() : void
		{
			if (mParent)
			{
				mParentX = mParent.x;
				mParentY = mParent.y;
				mParentAlpha = mParent.alpha;
				var oldAlpha : Number = mAlpha;
				alpha = 0;
				alpha = oldAlpha;
				var oldX : int = mX;
				var oldY : int = mY;
				mX = mY = int.MIN_VALUE;
				x = oldX;
				y = oldY;
			}
		}

		private function notifyRemovedFromRender() : void
		{
			mRender && mRender.removeFromParent();
			for (var i : int = 0; i < mNumChildren; i++)
			{
				mChilds[i].notifyRemovedFromRender();
			}
		}

		public function addChild(child : SRender) : SRender
		{
			if (childs.indexOf(child) == -1)
			{
				child.setParent(this);
				sort2Push(child);
				child.notifyAddedToRender();
			}
			return child;
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
				mChilds.push(child);
				mNumChildren++;
				mParent.sort2Push(child);
				return;
			}
			var tIndex : int = mChilds.indexOf(child as IDisplayRender);
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
					if (child.layer > mChilds[tSortIndex + 1].layer)
						tSortIndex++;
					else
						tSortIndex--;
				}
				//向后查找
				if (child.layer > mChilds[tSortIndex].layer)
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
				if (child.layer < mChilds[tSortIndex].layer)
				{
					break;
				}
			}

			//移除以前的
			if (tIndex != -1)
				mChilds.splice(tIndex, 1);
			else
				mNumChildren++;
			if (tIndex >= 0 && tIndex < tSortIndex)
				tSortIndex--;
			if (tSortIndex < 0)
				tSortIndex = 0;
			//插入
			mChilds.splice(tSortIndex, 0, child);
			mParent.sort2Push(child);
		}

		public function removeDisplay(child : IDisplayObject, dispose : Boolean = false) : IDisplayObject
		{
			return removeChildAt(childs.indexOf(child as IDisplayRender));
		}

		public function removeChildAt(index : int) : IDisplayRender
		{
			if (index < 0 || index >= mNumChildren)
				return null;
			mNumChildren--;
			var child : IDisplayRender = childs.splice(index, 1)[0];
			mParent && mParent.removeDisplay(child);
			child.setParent(null);
			return child;
		}

		public function removeFromParent(dispose : Boolean = false) : void
		{
			if (mParent)
				mParent.removeDisplay(this, dispose);
			else if (dispose)
				this.dispose();
			mParent = null;
		}

		public function getChildAt(index : int) : IDisplayRender
		{
			if (index < 0 || index >= mNumChildren)
				return null;
			return childs[index];
		}

		public function getChildIndex(child : SRender) : int
		{
			return childs.indexOf(child);
		}

		public function getChildByName(name : String) : IDisplayRender
		{
			var child : IDisplayRender;
			for (var i : int = 0; i < mNumChildren; i++)
			{
				child = childs[i];
				if (child.name == name)
					return child;
			}
			return null;
		}

		private function get childs() : Vector.<IDisplayRender>
		{
			if (mChilds == null)
				mChilds = new Vector.<IDisplayRender>();
			return mChilds;
		}

		public function get numChildren() : int
		{
			return mNumChildren;
		}

		public function get parent() : IDisplayObjectContainer
		{
			return mParent;
		}

		public function setParent(value : IDisplayObjectContainer) : void
		{
			if (mParent == value)
				return;
			mParent = value as IDisplayRender;
			mParent ? notifyAddedToRender() : notifyRemovedFromRender();
		}

		public function get x() : Number
		{
			return mX;
		}

		public function set x(value : Number) : void
		{
			if (mX == value)
				return;
			mX = value;
			if (mRender)
			{
				mRender.x = mX + mParentX;
				updateChildByField("parentX", mX);
			}
		}

		name_part function set parentX(value : Number) : void
		{
			if (mParentX == value)
				return;
			mParentX = value;
			if (mRender)
				mRender.x = mX + mParentX;
		}

		name_part function set parentY(value : Number) : void
		{
			if (mParentY == value)
				return;
			mParentY = value;
			if (mRender)
				mRender.y = mY + mParentY;
		}

		public function get y() : Number
		{
			return mY;
		}

		public function set y(value : Number) : void
		{
			if (mY == value)
				return;
			mY = value;

			if (mRender)
			{
				mRender.y = mY + mParentY;
				updateChildByField("parentY", mY);
			}
		}


		/**
		 * 赋值无效
		 * @param value
		 *
		 */
		public function set width(value : Number) : void
		{
		}


		/**
		 * 赋值无效
		 * @param value
		 *
		 */
		public function set height(value : Number) : void
		{
		}

		public function get width() : Number
		{
			if (!mRender)
				return 0;
			return mRender.width;
		}

		public function get height() : Number
		{
			if (!mRender)
				return 0;
			return mRender.height;
		}

		public function get scaleX() : Number
		{
			return mScaleX;
		}

		public function set scaleX(value : Number) : void
		{
			if (mScaleX == value)
				return;
			mScaleX = value;
			if (mRender)
				mRender.scaleX = mScaleX;
		}

		public function get scaleY() : Number
		{
			return mScaleY;
		}

		public function set scaleY(value : Number) : void
		{
			if (mScaleY == value)
				return;
			mScaleY = value;
			if (mRender)
				mRender.scaleY = mScaleY;
		}

		public function get alpha() : Number
		{
			return mAlpha;
		}

		public function set alpha(value : Number) : void
		{
			if (mAlpha == value)
				return;
			mAlpha = value;
			if (mRender)
				mRender.alpha = mAlpha * mParentAlpha;
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
			if (mRender)
				mRender.filters = mFilters;
		}

		public function get rotation() : Number
		{
			return mRotation;
		}

		public function set rotation(value : Number) : void
		{
			if (mRotation == value)
				return;
			mRotation = value;
			if (mRender)
				mRender.rotation = mRotation;
		}

		public function get blendMode() : String
		{
			return mBlendMode;
		}

		public function set blendMode(value : String) : void
		{
			if (mBlendMode == value)
				return;
			mBlendMode = value;
			if (mRender)
				mRender.blendMode = mBlendMode;
		}

		public function get colorTransform() : ColorTransform
		{
			return mTransform;
		}

		public function set colorTransform(value : ColorTransform) : void
		{
			if (mTransform == value)
				return;
			mTransform = value;
			if (mRender)
				mRender.colorTransform = mTransform;
		}

		public function get visible() : Boolean
		{
			return mVisible;
		}

		public function set visible(value : Boolean) : void
		{
			if (mVisible == value)
				return;
			mVisible = value;
			if (mRender)
				mRender.visible = mVisible;
		}

		/**
		 * render中的层级
		 * @return
		 *
		 */
		public function get layer() : int
		{
			return mIndex;
		}

		public function set layer(value : int) : void
		{
			if (mLayer == value)
				return;
			mLayer = value;
			mIndex = mDepth + mLayer;
			mParent && mParent.sort2Push(this);
		}

		/**
		 * 深度，一般设置为场景坐标
		 * @param value
		 *
		 */
		public function set depth(value : int) : void
		{
			if (mDepth == value)
				return;
			mDepth = value;
			mIndex = mDepth + mLayer;
			mParent && mParent.sort2Push(this);
		}

		public function render() : void
		{
			mRender.render();
		}

		public function set bitmapData(value : IBitmapData) : void
		{
			if (mBitmapData == value)
				return;
			mBitmapData = value;
			display.data = value;
		}

		public function get bitmapData() : IBitmapData
		{
			return display.data;
		}

		private function updateChildByField(field : String, value : *) : void
		{
			if (mNumChildren == 0)
				return;
			for (var i : int = 0; i < mNumChildren; i++)
			{
				mChilds[i][field] = value;
			}
		}

		public function set dropShadow(value : Boolean) : void
		{
			mRender.dropShadow = value;
		}

		/**
		 * 回收
		 *
		 */
		public function recycle() : void
		{
			SMemeryManager.recycleObject(this);
		}

		/**
		 * 暂时没用到
		 * @param type
		 * @param data
		 *
		 */
		public function dispatchEventWith(type : String, data : Object = null) : void
		{

		}

		public function get name() : String
		{
			return mName;
		}

		public function set name(value : String) : void
		{
			mName = value;
		}

		public function get display() : IBitmap
		{
			return mRender;
		}

		public function dispose() : void
		{
			removeFromParent();
			while (mNumChildren > 0)
				removeChildAt(0);
			bitmapData = null;
			mNumChildren = 0;
		}
	}
}