package hy.game.render
{
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;

	import hy.game.cfg.Config;
	import hy.game.core.interfaces.IBitmap;
	import hy.game.core.interfaces.IBitmapData;
	import hy.game.core.interfaces.IGameContainer;
	import hy.game.core.interfaces.IRecycle;
	import hy.game.core.interfaces.IRender;
	import hy.game.manager.SObjectManager;
	import hy.game.namespaces.name_part;
	import hy.game.stage3D.interfaces.IDisplayObject;
	import hy.game.stage3D.interfaces.IDisplayObjectContainer;
	import hy.rpg.utils.UtilsCommon;

	use namespace name_part;

	/**
	 * 游戏显示对象
	 * @author hyy
	 *
	 */
	public class SRender implements IRender, IRecycle
	{
		private static var sIds : uint = 0;
		private static var sMatrix : Matrix = new Matrix();
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
		private var mDepth : int;
		private var mIndex : int;
		private var mLayer : int;
		private var mVisible : Boolean;
		private var mBlendMode : String;
		private var mParent : IRender;
		private var mTransform : ColorTransform
		private var mFilters : Array;
		private var mChilds : Vector.<IRender>;
		private var mContainer : IGameContainer;

		public function SRender()
		{
			mId = sIds++;
			mAlpha = mParentAlpha = 1.0;
			if (Config.supportDirectX)
				mRender = new SDirectBitmap();
			else
				mRender = new SRenderBitmap();
		}

		public function notifyAddedToRender() : void
		{
			if (mParent)
			{
				mParentX = mParent.x;
				mParentY = mParent.y;
				mParentAlpha = mParent.alpha;
				var oldAlpha : Number = mAlpha;
				alpha = 0;
				alpha = oldAlpha;
				mDepth = mParent.zDepth;
				var oldX : int = mX;
				var oldY : int = mY;
				mX = mY = int.MIN_VALUE;
				x = oldX;
				y = oldY;
			}
		}

		public function notifyRemovedFromRender() : void
		{
			mRender && mRender.removeFromParent();
			for (var i : int = 0; i < mNumChildren; i++)
			{
				mChilds[i].notifyRemovedFromRender();
			}
		}

		public function set container(value : IGameContainer) : void
		{
			mContainer = value;
			if (!mContainer)
				notifyRemovedFromRender();
		}

		public function addChild(child : SRender) : SRender
		{
			if (childs.indexOf(child) == -1)
			{
				child.setParent(this);
				sort2Push(child);
				mNumChildren++;
				child.notifyAddedToRender();
			}
			return child;
		}


		public function sort2Push(child : IRender) : void
		{
			if (mNumChildren == 0)
			{
				mChilds.push(child);
				mContainer.addChildRender(child as SRender, child.parent.index + 1);
				return;
			}
			var tIndex : int = mChilds.indexOf(child);
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
			for (var i : int = tStartSortIndex; i <= tEndSortIndex; i++)
			{
				if (child.layer < mChilds[i].layer)
				{
					break;
				}
			}

			//移除以前的
			if (tIndex != -1)
				mChilds.splice(tIndex, 1);
			//插入
			mChilds.splice(tIndex == -1 || tIndex > i ? i : i + 1, 0, child);
			mContainer.addChildRender(child as SRender, child.parent.index + 1 + i);
		}

		public function removeChild(child : IDisplayObject, dispose : Boolean = false) : IDisplayObject
		{
			return removeChildAt(childs.indexOf(child as IRender));
		}

		public function removeChildAt(index : int) : IRender
		{
			if (index < 0 || index >= mNumChildren)
				return null;
			mNumChildren--;
			var child : IRender = childs.splice(index, 1)[0];
			child.notifyRemovedFromRender();
			child.setParent(null);
			return child;
		}

		public function removeFromParent(dispose : Boolean = false) : void
		{
			if (mParent)
				mParent.removeChild(this, dispose);
			else if (dispose)
				this.dispose();
		}

		public function getChildAt(index : int) : IRender
		{
			if (index < 0 || index >= mNumChildren)
				return null;
			return childs[index];
		}

		public function getChildIndex(child : SRender) : int
		{
			return childs.indexOf(child);
		}

		public function getChildByName(name : String) : IRender
		{
			var child : IRender;
			for (var i : int = 0; i < mNumChildren; i++)
			{
				child = childs[i];
				if (child.name == name)
					return child;
			}
			return null;
		}

		private function get childs() : Vector.<IRender>
		{
			if (mChilds == null)
				mChilds = new Vector.<IRender>();
			return mChilds;
		}

		public function removeAllChildren() : void
		{
			while (mNumChildren > 0)
			{
				removeChildAt(mNumChildren - 1);
			}
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
			mParent = value as IRender;
		}

		/**
		 * 通过弧度旋转
		 * @param rotate 相对于原矩阵要旋转的弧度值
		 * @param pointX 旋转基点
		 * @param pointY 旋转基点
		 */
		public function rotate(rotate : Number, pointX : int = 0, pointY : int = 0) : void
		{
			var angle : int = UtilsCommon.getAngleByRotate(rotate);
			sMatrix.identity();
			sMatrix.translate(-pointX, -pointY);
			sMatrix.rotate(rotate);
			sMatrix.translate(pointX, pointY);
			mRender.rotation = angle;
			x += sMatrix.tx;
			y += sMatrix.ty;
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
		 * 容器中的深度 （只读）
		 * @param value
		 *
		 */
		public function get zDepth() : int
		{
			return mDepth;
		}

		/**
		 * 设置深度，用于深度排序
		 * @param value
		 *
		 */
		name_part function set depth(value : int) : void
		{
			mDepth = value;
			mContainer && mContainer.changeDepthSort();
		}

		/**
		 * 所在容器中的索引
		 * @return
		 *
		 */
		public function get index() : int
		{
			return mIndex;
		}

		public function set index(value : int) : void
		{
			mIndex = value;
		}

		/**
		 * render中的层级
		 * @return
		 *
		 */
		public function get layer() : int
		{
			return mLayer;
		}

		public function set layer(value : int) : void
		{
			if (mLayer == value)
				return;
			mLayer = value;
			mParent && mParent.sort2Push(this);
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

		public function render() : void
		{

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
			SObjectManager.recycleObject(this);
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

		public function dispose() : void
		{
			if (parent)
			{
				parent.removeChild(this);
				setParent(null);
			}
			while (mNumChildren > 0)
				removeChildAt(0);
			bitmapData = null;
			mNumChildren = 0;
		}
	}
}