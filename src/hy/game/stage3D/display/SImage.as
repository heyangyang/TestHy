package hy.game.stage3D.display
{
	import flash.display3D.VertexBuffer3D;
	import flash.display3D.textures.TextureBase;

	import hy.game.stage3D.SRenderSupport;
	import hy.game.stage3D.texture.STexture;
	import hy.game.stage3D.texture.STextureSmoothing;
	import hy.game.stage3D.utils.SVertexBuffer3D;

	public class SImage extends SDisplayObject
	{
		private var mTexture : STexture;
		private var mSmoothing : String;
		private var mDropShadow : Boolean;
		private var mIsChange : Boolean;
		private var mVertexBuffer3D : SVertexBuffer3D;

		public function SImage(value : STexture = null)
		{
			if (value)
				this.texture = value;
			super();
		}

		public function get texture() : STexture
		{
			return mTexture;
		}

		public function get base() : TextureBase
		{
			return mTexture.base;
		}

		public function set texture(value : STexture) : void
		{
			if (!value)
			{
				mTexture = null;
				return;
			}
			mTexture = value;
			mSmoothing = STextureSmoothing.BILINEAR;
			isChange = mIsChange;
		}

		public function get smoothing() : String
		{
			return mSmoothing;
		}

		public function set smoothing(value : String) : void
		{
			if (STextureSmoothing.isValid(value))
				mSmoothing = value;
			else
				throw new ArgumentError("Invalid smoothing mode: " + value);
		}

		public function get tinted() : Boolean
		{
			return true;
		}

		public override function get width() : Number
		{
			return mTexture ? mTexture.width : 0;
		}

		public override function get height() : Number
		{
			return mTexture ? mTexture.height : 0;
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

		private function set isChange(value : Boolean) : void
		{
			mIsChange = value;
			if (mIsChange)
				mVertexBuffer3D = mTexture.updateVertexBuffer3D(scaleX, rotation);
			else
			{
				mVertexBuffer3D && mVertexBuffer3D.release();
				mVertexBuffer3D = null;
			}
		}

		public function get vertexBuffer3D() : VertexBuffer3D
		{
			return mVertexBuffer3D ? mVertexBuffer3D.data : mTexture.vertexBuffer3D;
		}

		public function get dropShadow() : Boolean
		{
			return mDropShadow;
		}

		public function set dropShadow(value : Boolean) : void
		{
			mDropShadow = value;
		}

		public override function dispose() : void
		{
			super.dispose();
			isChange = false;
			mTexture = null;
		}

	}
}