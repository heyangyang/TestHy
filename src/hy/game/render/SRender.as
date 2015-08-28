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
		private var mRender : IBitmap;
		private var mBitmapData : IBitmapData;
		private var mName : String;
		name_part var mParentX : int;
		name_part var mParentY : int;
		name_part var mParentAlpha : Number;
		private var mX : int = int.MIN_VALUE;
		private var mY : int = int.MIN_VALUE;
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

		public function addChild(child : IRender) : IRender
		{
			if (childs.indexOf(child) == -1)
			{
				mNumChildren++;
				child.parent = this;
				mChilds.push(child);
				updateChildIndex(child);
				child.notifyAddedToRender();
			}
			return child;
		}

		public function updateChildIndex(child : IRender) : void
		{
			var index : int = childs.indexOf(child);
			if (index == -1)
				throw new Error("SRender indexOf == -1");
			for (var i : int = 0; i < numChildren; i++)
			{
				//跳过自己
				if (i == index)
					continue;
				//大于对方，则进行下一次比较
				if (child.layer > mChilds[i].layer)
					continue;
				break;
			}
			//插入前面一个
			mChilds.splice(i, 0, child);
			//移除以前的
			mChilds.splice(i > index ? index : index + 1, 1);
			mContainer.addChildRender(child as SRender, child.parent.index + 1 + i);
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
			mParent && mParent.updateChildIndex(this);
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