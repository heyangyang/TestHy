package hy.game.stage3D
{
	import flash.geom.Rectangle;

	public class SImage extends SQuad
	{
		private var mTexture : STexture;
		private var mSmoothing : String;

		public function SImage(texture : STexture = null)
		{
			this.texture = texture;
			super(0, 0, 0xffffff, false);
		}

		public function get texture() : STexture
		{
			return mTexture;
		}

		public function set texture(texture : STexture) : void
		{
			if (!texture)
				return;
			var frame : Rectangle = texture.frame;
			var width : Number = frame ? frame.width : texture.width;
			var height : Number = frame ? frame.height : texture.height;
			var pma : Boolean = texture.premultipliedAlpha;

			mVertexData.setTexCoords(0, 0.0, 0.0);
			mVertexData.setTexCoords(1, 1.0, 0.0);
			mVertexData.setTexCoords(2, 0.0, 1.0);
			mVertexData.setTexCoords(3, 1.0, 1.0);

			setSize(width, height);
			mVertexData.premultipliedAlpha = pma;

			mTexture = texture;
			mTexture.adjustVertexData(mVertexData);
			mSmoothing = STextureSmoothing.BILINEAR;
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
	}
}