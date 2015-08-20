package hy.game.stage3D.display
{
	import flash.geom.Matrix;

	import hy.game.stage3D.SRenderSupport;
	import hy.game.stage3D.texture.STexture;
	import hy.game.stage3D.texture.STextureSmoothing;
	import hy.game.stage3D.utils.SVertexData;

	public class SImage extends SQuad
	{
		private var mTexture : STexture;
		private var mSmoothing : String;
		protected var mSupportVertexData : SVertexData;

		public function SImage(texture : STexture = null)
		{
			this.texture = texture;
			super(0, 0, 0xffffff, true);
		}

		public function get texture() : STexture
		{
			return mTexture;
		}

		public function set texture(texture : STexture) : void
		{
			if (!texture)
				return;
			mVertexData.setTexCoords(0, 0.0, 0.0);
			mVertexData.setTexCoords(1, 1.0, 0.0);
			mVertexData.setTexCoords(2, 0.0, 1.0);
			mVertexData.setTexCoords(3, 1.0, 1.0);

			setSize(texture.width, texture.height);
			mSupportVertexData = new SVertexData(4);
			mTexture = texture;
			mTexture.adjustVertexData(mVertexData);
			copyVertexDataTransformedTo(mSupportVertexData, transformationMatrix);
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

		public override function get tinted() : Boolean
		{
			return true;
		}

		public override function get transformationMatrix() : Matrix
		{
			if (mOrientationChanged)
				copyVertexDataTransformedTo(mSupportVertexData, super.transformationMatrix);
			return super.transformationMatrix;
		}

		public override function get rawData() : Vector.<Number>
		{
			return mSupportVertexData.rawData;
		}

		public override function render() : void
		{
			if (mTexture == null)
				return;
			transformationMatrix;
			SRenderSupport.updateProgram(mTexture, tinted, mSmoothing);
			SRenderSupport.supportImage(this);
		}
	}
}