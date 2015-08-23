package hy.game.stage3D.display
{
	import flash.display3D.textures.TextureBase;
	import flash.geom.Matrix;
	
	import hy.game.stage3D.SRenderSupport;
	import hy.game.stage3D.texture.STexture;
	import hy.game.stage3D.texture.STextureSmoothing;
	import hy.game.stage3D.utils.SVertexData;

	public class SImage extends SQuad
	{
		private var mTexture : STexture;
		private var mSmoothing : String;
		private var mDropShadow:Boolean;
		protected var mSupportVertexData : SVertexData;

		public function SImage(value : STexture = null)
		{
			if(value)
				this.texture = value;
			super(0, 0, 0xffffff, true);
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
				mTexture=null;
				return;
			}
			mVertexData.setTexCoords(0, 0.0, 0.0);
			mVertexData.setTexCoords(1, 1.0, 0.0);
			mVertexData.setTexCoords(2, 0.0, 1.0);
			mVertexData.setTexCoords(3, 1.0, 1.0);

			setSize(value.width, value.height);
			mSupportVertexData = new SVertexData(4);
			mTexture = value;
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
		
		public override function get width():Number
		{
			return mTexture?mTexture.width:0;
		}
		
		public override function get height():Number
		{
			return mTexture?mTexture.height:0;
		}


		public function get vertexData() : SVertexData
		{
			return mSupportVertexData;
		}

		public override function render() : void
		{
			if (mTexture == null)
				return;
			transformationMatrix;
			SRenderSupport.supportImage(this);
		}

		public function get dropShadow():Boolean
		{
			return mDropShadow;
		}

		public function set dropShadow(value:Boolean):void
		{
			mDropShadow = value;
		}

	}
}