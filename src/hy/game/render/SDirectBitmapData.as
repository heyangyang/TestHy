package hy.game.render
{
	import flash.display.BitmapData;
	import flash.display3D.Context3DTextureFormat;
	import flash.geom.Rectangle;

	import hy.game.interfaces.display.IBitmapData;
	import hy.game.stage3D.texture.STexture;

	public class SDirectBitmapData extends STexture implements IBitmapData
	{

		/**
		 * format强制设置为 Context3DTextureFormat.COMPRESSED_ALPHA
		 * @param data
		 * @param generateMipMaps
		 * @param optimizeForRenderToTexture
		 * @param scale
		 * @param repeat
		 * @return 
		 * 
		 */
		public static function fromDirectBitmapData(data : BitmapData, generateMipMaps : Boolean = true, optimizeForRenderToTexture : Boolean = false, scale : Number = 1, repeat : Boolean = false) : SDirectBitmapData
		{
			return STexture.fromBitmapData(data, false, optimizeForRenderToTexture, scale, Context3DTextureFormat.COMPRESSED_ALPHA, repeat) as SDirectBitmapData;
		}

		public static function directEmpty(width : Number, height : Number, premultipliedAlpha : Boolean = true, mipMapping : Boolean = true, optimizeForRenderToTexture : Boolean = false, scale : Number = -1, format : String = "bgra", repeat : Boolean = false) : SDirectBitmapData
		{
			return STexture.empty(width, height, premultipliedAlpha, mipMapping, optimizeForRenderToTexture, scale, format, repeat) as SDirectBitmapData;
		}

		protected var _rect : Rectangle;

		public function SDirectBitmapData()
		{
			super();
		}

		public function get rect() : Rectangle
		{
			if (_rect == null)
				_rect = new Rectangle(0, 0, width, height);
			return _rect;
		}

		public function getPixel(x : int, y : int) : uint
		{
			return 0;
		}

		public function cloneData() : IBitmapData
		{
			return null;
		}
	}
}