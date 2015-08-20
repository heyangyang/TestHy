package hy.game.render
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.ColorTransform;

	import hy.game.core.interfaces.IBitmap;
	import hy.game.core.interfaces.IBitmapData;

	public class SRenderBitmap extends Bitmap implements IBitmap
	{
		public function SRenderBitmap(bitmapData : BitmapData = null, pixelSnapping : String = "auto", smoothing : Boolean = false)
		{
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

		public function dispose() : void
		{
			if (bitmapData)
				bitmapData.dispose();
		}
	}
}