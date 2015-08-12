package hy.game.render
{
	import flash.display.BitmapData;
	import flash.geom.ColorTransform;
	import flash.geom.Rectangle;
	
	import hy.game.core.interfaces.IBitmap;
	import hy.game.core.interfaces.IBitmapData;
	
	import starling.display.Image;
	import starling.textures.Texture;

	public class SDirectBitmap extends Image implements IBitmap
	{
		private static var nullTexture : SDirectBitmapData

		public function SDirectBitmap(texture : SDirectBitmapData = null)
		{
			if (nullTexture == null)
				nullTexture = SDirectBitmapData.directEmpty(2, 2);
			if (texture == null)
				texture = nullTexture;
			super(texture);
		}

		public function set data(value : IBitmapData) : void
		{
			if (value == null)
				value = nullTexture;
			if (value is SDirectBitmapData && texture != value)
			{
				this.texture = value as Texture;
				this.readjustSize();
			}
		}

		public function get data() : IBitmapData
		{
			return texture as IBitmapData;
		}

		public function set normal_bitmapData(value : BitmapData) : void
		{

		}

		public function get normal_bitmapData() : BitmapData
		{
			return null;
		}


		public function set filters(value : Array) : void
		{

		}

		public function get filters() : Array
		{
			return null;
		}

		public function removeChild() : void
		{
			parent && parent.removeChild(this);
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


		public function destroy() : void
		{
			removeChild();
			if (texture)
				texture.dispose();
		}

	}
}