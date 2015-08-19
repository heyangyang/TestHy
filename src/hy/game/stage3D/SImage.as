package hy.game.stage3D
{
	import flash.geom.Rectangle;

	import starling.textures.TextureSmoothing;
	import starling.utils.VertexData;

	public class SImage extends SQuad
	{
		public function SImage(texture : STexture = null)
		{
			this.texture = texture;
			super(0, 0, 0xffffff, false);
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
			mSmoothing = TextureSmoothing.BILINEAR;
			mVertexDataCache = new VertexData(4, pma);
			mVertexDataCacheInvalid = true;
		}
	}
}