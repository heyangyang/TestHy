package hy.game.stage3D.texture
{
	import flash.display.BitmapData;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.textures.Texture;
	import flash.display3D.textures.TextureBase;
	import flash.utils.ByteArray;
	
	import hy.game.data.SRectangle;
	import hy.game.stage3D.SStage3D;
	import hy.game.stage3D.errors.MissingContextError;
	import hy.game.stage3D.utils.SVertexData;
	import hy.game.stage3D.utils.getNextPowerOfTwo;



	public class STexture
	{
		public static function fromBitmapData(data : BitmapData, generateMipMaps : Boolean = true, optimizeForRenderToTexture : Boolean = false, scale : Number = 1, format : String = "bgra", repeat : Boolean = false) : STexture
		{
			var texture : STexture = empty(data.width / scale, data.height / scale, true, generateMipMaps, optimizeForRenderToTexture, scale, format, repeat);
			texture.root.uploadBitmapData(data);
			return texture;
		}

		public static function fromAtfData(data : ByteArray, scale : Number = 1, useMipMaps : Boolean = true, repeat : Boolean = false) : STexture
		{
			var context : Context3D = SStage3D.context;
			if (context == null)
				throw new MissingContextError();

			var atfData : SAtfData = new SAtfData(data);
			var nativeTexture : flash.display3D.textures.Texture = context.createTexture(atfData.width, atfData.height, atfData.format, false);
			var concreteTexture : SConcreteTexture = new SConcreteTexture(nativeTexture, atfData.format, atfData.width, atfData.height, useMipMaps && atfData.numTextures > 1, false, false, scale, repeat);
			concreteTexture.uploadAtfData(data, 0);
			return concreteTexture;
		}

		public static function empty(width : Number, height : Number, premultipliedAlpha : Boolean = true, mipMapping : Boolean = true, optimizeForRenderToTexture : Boolean = false, scale : Number = -1, format : String = "bgra", repeat : Boolean = false) : STexture
		{
			var actualWidth : int, actualHeight : int;
			var nativeTexture : TextureBase;
			var context : Context3D = SStage3D.context;

			if (context == null)
				throw new MissingContextError();

			var origWidth : Number = width * scale;
			var origHeight : Number = height * scale;
			var useRectTexture : Boolean = !mipMapping && !repeat && SStage3D.current.profile != "baselineConstrained" && "createRectangleTexture" in context && format.indexOf("compressed") == -1;

			if (useRectTexture)
			{
				actualWidth = Math.ceil(origWidth - 0.000000001); // avoid floating point errors
				actualHeight = Math.ceil(origHeight - 0.000000001);

				// Rectangle Textures are supported beginning with AIR 3.8. By calling the new
				// methods only through those lookups, we stay compatible with older SDKs.
				context.createRectangleTexture
				nativeTexture = context["createRectangleTexture"](actualWidth, actualHeight, format, optimizeForRenderToTexture);
			}
			else
			{
				actualWidth = getNextPowerOfTwo(origWidth);
				actualHeight = getNextPowerOfTwo(origHeight);

				nativeTexture = context.createTexture(actualWidth, actualHeight, format, optimizeForRenderToTexture);
			}

			var concreteTexture : SConcreteTexture = new SConcreteTexture(nativeTexture, format, actualWidth, actualHeight, mipMapping, premultipliedAlpha, optimizeForRenderToTexture, scale, repeat);

			if (actualWidth - origWidth < 0.001 && actualHeight - origHeight < 0.001)
				return concreteTexture;
			else
				return new SSubTexture(concreteTexture, new SRectangle(0, 0, width, height));
		}

		public static function fromData(data : ByteArray, options : STextureOptions = null) : STexture
		{
			if (options == null)
				options = new STextureOptions();
			var texture : STexture = fromAtfData(data as ByteArray, options.scale, options.mipMapping, options.repeat);
			return texture;
		}

		public function STexture()
		{
		}

		public function get width() : int
		{
			return 0;
		}

		public function get height() : int
		{
			return 0;
		}

		public function get base() : TextureBase
		{
			return null;
		}

		public function get mipMapping() : Boolean
		{
			return false;
		}

		public function get scale() : Number
		{
			return 1.0;
		}

		public function get repeat() : Boolean
		{
			return false;
		}

		public function get format() : String
		{
			return Context3DTextureFormat.BGRA;
		}

		public function get root() : SConcreteTexture
		{
			return null;
		}

		public function adjustVertexData(vertexData : SVertexData) : void
		{

		}

		public function adjustTexCoords(texCoords : Vector.<Number>, startIndex : int = 0, stride : int = 0, count : int = -1) : void
		{

		}

		public function get vertexData() : SVertexData
		{
			return null;
		}

		public function dispose() : void
		{

		}
	}
}