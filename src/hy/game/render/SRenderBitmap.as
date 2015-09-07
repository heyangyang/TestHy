package hy.game.render
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;

	import hy.game.interfaces.display.IBitmap;
	import hy.game.interfaces.display.IBitmapData;
	import hy.game.interfaces.display.IDisplayContainer;
	import hy.rpg.utils.UtilsCommon;

	public class SRenderBitmap extends Bitmap implements IBitmap
	{
		private static var sMatrix : Matrix = new Matrix();
		private var mOffsetX : Number;
		private var mOffsetY : Number;
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
		/**
		 *  容器
		 */
		private var mParent : IDisplayContainer;

		public function SRenderBitmap(bitmapData : BitmapData = null, pixelSnapping : String = "auto", smoothing : Boolean = false)
		{
			mOffsetX = mOffsetY = 0.0;
			super(bitmapData, pixelSnapping, smoothing);
		}

		public function render() : void
		{

		}

		public function set data(value : IBitmapData) : void
		{
			this.bitmapData = value as BitmapData;
		}

		public function get data() : IBitmapData
		{
			return bitmapData as IBitmapData;
		}

		public function removeFromParent(dispose : Boolean = false) : void
		{
			if (dispose && bitmapData)
				bitmapData.dispose();
			mParent && mParent.removeDisplay(this);
		}

		public function set colorTransform(value : ColorTransform) : void
		{
			transform.colorTransform = value;
		}

		public function get colorTransform() : ColorTransform
		{
			return transform.colorTransform;
		}

		override public function set rotation(value : Number) : void
		{
			var angle : int = UtilsCommon.getAngleByRotate(value);
			sMatrix.identity();
			//中心旋转
			sMatrix.translate(-width >> 1, -height >> 1);
			sMatrix.rotate(angle);
			sMatrix.translate(width >> 1, height >> 1);
			mOffsetX = sMatrix.tx;
			mOffsetY = sMatrix.ty;
			super.x += mOffsetX;
			super.y += mOffsetY;
		}

		override public function set x(value : Number) : void
		{
			super.x = value + mOffsetX;
		}

		override public function set y(value : Number) : void
		{
			super.y = value + mOffsetY;
		}


		public function setParent(value : IDisplayContainer) : void
		{
			if (mParent == value)
				return;
			mParent = value;
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
			mParent && mParent.addDisplay(this);
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
			mParent && mParent.addDisplay(this);
		}

		public function get depth() : int
		{
			return mDepth;
		}

		public function set colorFilter(value : *) : void
		{
			if (value && value.length == 0)
				value = null;
			filters = value;
		}

		public function get colorFilter() : *
		{
			return filters;
		}

		public function dispose() : void
		{
			if (bitmapData)
				bitmapData.dispose();
		}
	}
}