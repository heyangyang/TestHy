package hy.game.stage3D.texture
{
	import flash.display.BitmapData;
	import flash.display3D.textures.Texture;
	import flash.display3D.textures.TextureBase;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	
	import hy.game.render.SDirectBitmapData;
	import hy.game.stage3D.SVertexBufferManager;
	import hy.game.stage3D.utils.SVertexBuffer3D;


	public class SConcreteTexture extends SDirectBitmapData
	{
		private var mBase : TextureBase;
		private var mFormat : String;
		private var mWidth : int;
		private var mHeight : int;
		private var mMipMapping : Boolean;
		private var mPremultipliedAlpha : Boolean;
		private var mOptimizedForRenderTexture : Boolean;
		private var mScale : Number;
		private var mRepeat : Boolean;
		private var mDataUploaded : Boolean;
		private var mVertexBuffer3D : SVertexBuffer3D;

		public function SConcreteTexture(base : TextureBase, format : String, width : int, height : int, mipMapping : Boolean, premultipliedAlpha : Boolean, optimizedForRenderTexture : Boolean = false, scale : Number = 1, repeat : Boolean = false)
		{
			mScale = scale <= 0 ? 1.0 : scale;
			mBase = base;
			mFormat = format;
			mWidth = width;
			mHeight = height;
			mMipMapping = mipMapping;
			mPremultipliedAlpha = premultipliedAlpha;
			mOptimizedForRenderTexture = optimizedForRenderTexture;
			mRepeat = repeat;
			mDataUploaded = false;
			mVertexBuffer3D = SVertexBufferManager.createVertexBuffer3D(width, height);
		}

		public override function get vertexBufferData() : SVertexBuffer3D
		{
			return mVertexBuffer3D;
		}
		
		public function uploadAtfData(data : ByteArray, offset : int = 0) : void
		{
			var potTexture : Texture = mBase as Texture;

			if (potTexture == null)
				throw new Error("This texture type does not support ATF data");
			potTexture.addEventListener(Event.TEXTURE_READY, onTextureReady);
			potTexture.uploadCompressedTextureFromByteArray(data, offset, true);
		}

		private function onTextureReady(evt : Event) : void
		{
			mBase.removeEventListener(Event.TEXTURE_READY, onTextureReady);
			mDataUploaded = true;
		}

		public function uploadBitmapData(data : BitmapData) : void
		{
			var potTexture : Texture = mBase as Texture;
			if (!potTexture)
				return;
			potTexture.uploadFromBitmapData(data);

			if (mMipMapping && data.width > 1 && data.height > 1)
			{
				var currentWidth : int = data.width >> 1;
				var currentHeight : int = data.height >> 1;
				var level : int = 1;
				var canvas : BitmapData = new BitmapData(currentWidth, currentHeight, true, 0);
				var transform : Matrix = new Matrix(.5, 0, 0, .5);
				var bounds : Rectangle = new Rectangle();

				while (currentWidth >= 1 || currentHeight >= 1)
				{
					bounds.width = currentWidth;
					bounds.height = currentHeight;
					canvas.fillRect(bounds, 0);
					canvas.draw(data, transform, null, null, null, true);
					potTexture.uploadFromBitmapData(canvas, level++);
					transform.scale(0.5, 0.5);
					currentWidth = currentWidth >> 1;
					currentHeight = currentHeight >> 1;
				}

				canvas.dispose();
			}
			mDataUploaded = true;
		}

		public override function get base() : TextureBase
		{
			return mDataUploaded ? mBase : null;
		}

		public function get optimizedForRenderTexture() : Boolean
		{
			return mOptimizedForRenderTexture;
		}

		public override function get format() : String
		{
			return mFormat;
		}

		public override function get width() : int
		{
			return mWidth / mScale;
		}

		public override function get height() : int
		{
			return mHeight / mScale;
		}

		public override function get scale() : Number
		{
			return mScale;
		}

		public override function get mipMapping() : Boolean
		{
			return mMipMapping;
		}

		public override function get root() : SConcreteTexture
		{
			return this;
		}

		public override function dispose() : void
		{
			if (mVertexBuffer3D)
			{
				mVertexBuffer3D.release();
				mVertexBuffer3D = null;
			}
			mBase && mBase.dispose();
			mBase = null;
			super.dispose();
		}
	}
}