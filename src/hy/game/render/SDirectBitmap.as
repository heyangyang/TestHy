package hy.game.render
{
	import flash.geom.ColorTransform;
	import flash.geom.Rectangle;

	import hy.game.interfaces.display.IBitmap;
	import hy.game.interfaces.display.IBitmapData;
	import hy.game.stage3D.SRenderSupport;
	import hy.game.stage3D.display.SImage;
	import hy.game.stage3D.texture.STexture;

	public class SDirectBitmap extends SImage implements IBitmap
	{
		private var mFilters : Array;

		public function SDirectBitmap(texture : SDirectBitmapData = null)
		{
			super(texture);
		}

		public function set data(value : IBitmapData) : void
		{
			if (texture != value)
			{
				this.texture = value as STexture;
			}
		}

		public function get data() : IBitmapData
		{
			return texture as IBitmapData;
		}

		public function set filters(value : Array) : void
		{
			if (value && value.length == 0)
				value = null;
			mFilters = value;
		}

		public function get filters() : Array
		{
			return mFilters;
		}

		public function removeChild() : void
		{
			parent && parent.removeDisplay(this);
		}

		public function set colorTransform(value : ColorTransform) : void
		{

		}

		public function get colorTransform() : ColorTransform
		{
			return null;
		}

		public function set scrollRect(rect : Rectangle) : void
		{
			this.x = rect.x;
			this.y = rect.y;
		}

		public override function render() : void
		{
			if (mTexture == null || mTexture.base == null)
				return;
			if (mOrientationChanged)
			{
				isChange = scaleX != 1.0 || rotation != 0.0;
				mOrientationChanged = false;
			}
			SRenderSupport.getInstance().supportImage(this);
		}

		public override function dispose() : void
		{
			super.dispose();
			mFilters = null;
		}

	}
}