package hy.game.render
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;

	import hy.game.core.interfaces.IBitmap;
	import hy.game.core.interfaces.IBitmapData;
	import hy.rpg.utils.UtilsCommon;

	public class SRenderBitmap extends Bitmap implements IBitmap
	{
		private static var sMatrix : Matrix = new Matrix();
		private var mOffsetX : Number;
		private var mOffsetY : Number;

		public function SRenderBitmap(bitmapData : BitmapData = null, pixelSnapping : String = "auto", smoothing : Boolean = false)
		{
			mOffsetX = mOffsetY = 0.0;
			super(bitmapData, pixelSnapping, smoothing);
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
			parent && parent.removeChild(this);
		}

		public function set colorTransform(value : ColorTransform) : void
		{
			transform.colorTransform = value;
		}

		public function get colorTransform() : ColorTransform
		{
			return transform.colorTransform;
		}

		public function set dropShadow(value : Boolean) : void
		{
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

		public function dispose() : void
		{
			if (bitmapData)
				bitmapData.dispose();
		}
	}
}