package hy.game.stage3D.display
{
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.VertexBuffer3D;
	import flash.display3D.textures.TextureBase;
	import flash.geom.Matrix;

	import hy.game.stage3D.SStage3D;
	import hy.game.stage3D.STextureSupport;
	import hy.game.stage3D.texture.STexture;
	import hy.game.stage3D.texture.STextureSmoothing;
	import hy.game.stage3D.utils.SVertexData;
	import hy.game.utils.SDebug;

	/**
	 * 批量处理
	 * @author hyy
	 *
	 */
	public class SQuadBath extends SDisplayObject
	{
		private static const MAX_NUM_QUADS : int = 16383;
		private static var sMatrix : Matrix = new Matrix();
		private var mChildren : Vector.<SImage>;
		private var mNumChildren : int;
		protected var mSmoothing : String;
		private var mSyncRequired : Boolean;
		//纹理
		private var mCurrSTexture : STexture;
		private var mTexture : TextureBase;
		//顶点数据
		private var mVertexData : SVertexData;
		private var mIndexData : Vector.<uint>;
		//stage3d
		private var mBuffer3D : VertexBuffer3D;
		private var mIndexBuffer : IndexBuffer3D;

		public function SQuadBath()
		{
			super();
			mChildren = new Vector.<SImage>();
			mVertexData = new SVertexData(0);
			mSmoothing = STextureSmoothing.BILINEAR;
			mIndexData = new Vector.<uint>();
		}

		public function addImage(child : SImage) : void
		{
			if (mNumChildren == 0)
			{
				mTexture = child.base;
				mCurrSTexture = child.texture;
			}
			if (mTexture != child.base)
			{
				SDebug.error(this, "texture is not same");
				return;
			}
			mSyncRequired = true;
			mVertexData.append(child.texture.vertexBufferData.vertexData);
			updateOrientation();
			sMatrix.translate(child.x, child.y);
			mVertexData.copyTransformedTo(mVertexData, mNumChildren, sMatrix, mNumChildren);
			mChildren.push(child);
			mNumChildren++;
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

		public function get base() : TextureBase
		{
			return mTexture;
		}

		public function get texture() : STexture
		{
			return mCurrSTexture;
		}

		public function get tinted() : Boolean
		{
			return true;
		}

		public function updateImage(child : STexture, x : Number, y : Number) : void
		{

		}

		private function updateOrientation() : void
		{
			if (!mOrientationChanged)
				return;
			mOrientationChanged = false;
			sMatrix.identity();
			if (rotation == 0.0)
			{
				sMatrix.setTo(scaleX, 0.0, 0.0, scaleY, 0.0, 0.0);
			}
			else
			{
				var cos : Number = Math.cos(rotation);
				var sin : Number = Math.sin(rotation);
				var a : Number = scaleX * cos;
				var b : Number = scaleX * sin;
				var c : Number = -sin;
				var d : Number = cos;

				sMatrix.setTo(a, b, c, d, 0.0, 0.0);
			}
		}

		public override function render() : void
		{
			if (mSyncRequired)
			{
				destroyBuffers();
				mBuffer3D = SStage3D.context.createVertexBuffer(mVertexData.numVertices, SVertexData.ELEMENTS_PER_VERTEX);
				mBuffer3D.uploadFromVector(mVertexData.rawData, 0, mVertexData.numVertices);

				capacity = mNumChildren;
				mIndexBuffer = SStage3D.context.createIndexBuffer(mIndexData.length);
				mIndexBuffer.uploadFromVector(mIndexData, 0, mIndexData.length)
			}
			STextureSupport.getInstance().supportQuadBath(this);
		}


		private function destroyBuffers() : void
		{
			if (mBuffer3D)
			{
				mBuffer3D.dispose();
				mBuffer3D = null;
			}
			if (mIndexBuffer)
			{
				mIndexBuffer.dispose();
				mIndexBuffer = null;
			}
		}

		private function set capacity(value : int) : void
		{
			var oldCapacity : int = mVertexData.numVertices / 4;

			if (value == oldCapacity)
				return;
			else if (value == 0)
				throw new Error("Capacity must be > 0");
			else if (value > MAX_NUM_QUADS)
				value = MAX_NUM_QUADS;

			mVertexData.numVertices = value * 4;
			mIndexData.length = value * 6;

			for (var i : int = oldCapacity; i < value; ++i)
			{
				mIndexData[int(i * 6)] = i * 4;
				mIndexData[int(i * 6 + 1)] = i * 4 + 1;
				mIndexData[int(i * 6 + 2)] = i * 4 + 2;
				mIndexData[int(i * 6 + 3)] = i * 4 + 1;
				mIndexData[int(i * 6 + 4)] = i * 4 + 3;
				mIndexData[int(i * 6 + 5)] = i * 4 + 2;
			}

			destroyBuffers();
			mSyncRequired = true;
		}

		public function get vertexBuffer3D() : VertexBuffer3D
		{
			return mBuffer3D;
		}

		public function get indexBuffer3d() : IndexBuffer3D
		{
			return mIndexBuffer;
		}

		public function cleanChild() : void
		{
			destroyBuffers();
			mIndexData.length = 0;
			mChildren.length = 0;
			mNumChildren = 0;
			mVertexData.numVertices = 0;
		}

		public override function dispose() : void
		{
			super.dispose();
			cleanChild();
			mChildren = null;
			mIndexData = null;
			mVertexData = null;
			mTexture = null;
			mCurrSTexture = null;
		}
	}
}