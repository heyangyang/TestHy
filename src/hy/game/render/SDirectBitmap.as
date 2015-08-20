package hy.game.render
{
	import flash.geom.ColorTransform;
	import flash.geom.Rectangle;
	
	import hy.game.core.interfaces.IBitmap;
	import hy.game.core.interfaces.IBitmapData;
	import hy.game.stage3D.display.SImage;
	import hy.game.stage3D.texture.STexture;

	public class SDirectBitmap extends SImage implements IBitmap
	{
		public function SDirectBitmap(texture : SDirectBitmapData = null)
		{
			super(texture);
		}

		public function set data(value : IBitmapData) : void
		{
			if (value is SDirectBitmapData && texture != value)
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


		public override function dispose() : void
		{
			super.dispose();
		}

	}
}