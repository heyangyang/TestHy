package hy.game.stage3D.display
{
	import flash.display3D.VertexBuffer3D;
	import flash.display3D.textures.TextureBase;
	import flash.geom.Matrix;
	
	import hy.game.stage3D.SRenderSupport;
	import hy.game.stage3D.SStage3D;
	import hy.game.stage3D.texture.STexture;
	import hy.game.stage3D.texture.STextureSmoothing;
	import hy.game.stage3D.utils.SVertexData;

	public class SImage extends SDisplayObject
	{
		private var mTexture : STexture;
		private var mSmoothing : String;
		private var mDropShadow : Boolean;
		private var mSupportVertexData : SVertexData;
		private var mVertexBuffer : VertexBuffer3D;

		public function SImage(value : STexture = null)
		{
			if (value)
				this.texture = value;
			mSupportVertexData = new SVertexData(4);
			mVertexBuffer = SStage3D.context.createVertexBuffer(vertexData.numVertices, SVertexData.ELEMENTS_PER_VERTEX);
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
			copyVertexDataTransformedTo(transformationMatrix);
			mVertexBuffer.uploadFromVector(mSupportVertexData.rawData, 0, mSupportVertexData.numVertices);
			mSmoothing = STextureSmoothing.BILINEAR;
		}

		public function copyVertexDataTransformedTo(matrix : Matrix = null) : void
		{
			mTexture.vertexData.copyTransformedTo(mSupportVertexData, 0, matrix, 0, 4);
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

		public override function get transformationMatrix() : Matrix
		{
			if (mOrientationChanged)
			{
				copyVertexDataTransformedTo(super.transformationMatrix);
				mVertexBuffer.uploadFromVector(mSupportVertexData.rawData, 0, mSupportVertexData.numVertices);
			}
			return super.transformationMatrix;
		}

		public override function get width() : Number
		{
			return mTexture ? mTexture.width : 0;
		}

		public override function get height() : Number
		{
			return mTexture ? mTexture.height : 0;
		}


		public function get vertexData() : SVertexData
		{
			return mSupportVertexData;
		}

		public override function render() : void
		{
			if (mTexture == null || mTexture.base == null)
				return;
			transformationMatrix;
			SRenderSupport.getInstance().supportImage(this);
		}

		public function get vertexBuffer3D() : VertexBuffer3D
		{
			return mVertexBuffer;
		}

		public function get dropShadow() : Boolean
		{
			return mDropShadow;
		}

		public function set dropShadow(value : Boolean) : void
		{
			mDropShadow = value;
		}

	}
}