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
		protected var mRender : IBitmap;
		protected var mBitmapData : IBitmapData;
		protected var mName : String;
		name_part var mParentX : int;
		name_part var mParentY : int;
		name_part var mParentAlpha : Number;
		protected var mX : int = int.MIN_VALUE;
		protected var mY : int = int.MIN_VALUE;
		protected var mScaleX : Number;
		protected var mScaleY : Number;
		protected var mNumChildren : int;
		protected var mAlpha : Number;
		protected var mRotation : Number;
		protected var mDepth : int;
		protected var mIndex : int;
		protected var mLayer : int;
		protected var mIsSortLayer : Boolean;
		protected var mVisible : Boolean;
		protected var mBlendMode : String;
		protected var mParent : IRender;
		protected var mTransform : ColorTransform
		protected var mFilters : Array;
		protected var mChilds : Vector.<IRender>;
		protected var mTmpIndex : int;
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

		/**
		 * 更新所有子元素层级
		 *
		 */
		private function updateIndex() : void
		{
			if (!mContainer)
				return;
			mTmpIndex = mContainer.getRenderIndex(this);
			updateIndexByRender(this);
		}

		private function updateIndexByRender(render : SRender) : void
		{
			var child : SRender;
			for (var i : int = 0; i < mNumChildren; i++)
			{
				child = mChilds[i] as SRender;
				mContainer.setChildRenderIndex(child, ++mTmpIndex);
				child.numChildren > 0 && updateIndexByRender(child);
			}
		}

		public function addChild(child : IRender) : IRender
		{
			return addChildAt(child, mNumChildren);
		}

		public function addChildAt(child : IRender, index : int) : IRender
		{
			if (childs.indexOf(child) == -1)
			{
				mContainer && mContainer.addChildRender(child as SRender, getRenderIndex(child));
				mNumChildren++;
				childs.push(child);
				mIsSortLayer = true;
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
			var index : int = mContainer.getRenderIndex(this) + 1;
			for (var i : int = 0; i < mNumChildren; i++)
			{
				if (child.layer >= mChilds[i].layer)
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
			if (index < 0 || index >= mNumChildren)
				return null;
			mNumChildren--;
			var child : IRender = childs.splice(index, 1)[0];
			child.notifyRemovedFromRender();
			child.parent = null;
			return child;
		}

		public function getChildAt(index : int) : IRender
		{
			if (index < 0 || index >= mNumChildren)
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

		public function get parent() : IRender
		{
			return mParent;
		}

		public function set parent(value : IRender) : void
		{
			if (mParent == value)
				return;
			mParent = value;
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
		 * 深度 （只读）
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

		public function get index() : int
		{
			return mIndex;
		}

		public function set index(value : int) : void
		{
			mIndex = value;
		}

		/**
		 * 层级
		 * @return
		 *
		 */
		public function get layer() : int
		{
			return mLayer;
		}

		public function set layer(value : int) : void
		{
			mLayer = value;
			if (mParent)
				mParent.needLayerSort = true;
		}

		public function get needLayerSort() : Boolean
		{
			return mIsSortLayer;
		}

		public function set needLayerSort(value : Boolean) : void
		{
			mIsSortLayer = true;
		}

		public function onLayerSort() : void
		{
			mChilds.sort(onSortLayer);
			updateIndex();
			mIsSortLayer = false;
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
			return mName;
		}

		public function set name(value : String) : void
		{
			mName = value;
		}

		public function get render() : IBitmap
		{
			return mRender;
		}

		public function set bitmapData(value : IBitmapData) : void
		{
			if (mBitmapData == value)
				return;
			mBitmapData = value;
			render.data = value;
		}

		public function get bitmapData() : IBitmapData
		{
			return render.data;
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

		public function dispose() : void
		{
			if (parent)
			{
				parent.removeChild(this);
				parent = null;
			}
			while (mNumChildren > 0)
				removeChildAt(0);
			bitmapData = null;
			mNumChildren = 0;
		}
	}
}