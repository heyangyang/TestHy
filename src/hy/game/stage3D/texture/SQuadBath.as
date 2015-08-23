package hy.game.stage3D.texture
{
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.VertexBuffer3D;
	import flash.geom.Matrix;
	
	import hy.game.stage3D.SStage3D;
	import hy.game.stage3D.display.SDisplayObject;
	import hy.game.stage3D.display.SQuad;
	import hy.game.stage3D.utils.SVertexData;

	public class SQuadBath extends SDisplayObject
	{
		/** The maximum number of quads that can be displayed by one QuadBatch. */
		public static const MAX_NUM_QUADS : int = 16383;
		private static var sHelperMatrix : Matrix = new Matrix();
		private static var sRenderAlpha:Vector.<Number> = new <Number>[1.0, 1.0, 1.0, 1.0];

		private var mNumQuads : int;
		private var mSyncRequired : Boolean;

		private var mVertexBuffer : VertexBuffer3D;
		private var mIndexData : Vector.<uint>;
		private var mIndexBuffer : IndexBuffer3D;
		protected var mVertexData : SVertexData;
		private var mContext : Context3D;

		public function SQuadBath()
		{
			mVertexData = new SVertexData(0);
			mIndexData = new <uint>[];
			mNumQuads = 0;
			mSyncRequired = false;
			mContext = SStage3D.context;
		}

		public function addQuad(quad : SQuad) : void
		{
			var vertexID : int = mNumQuads * 4;

			if (mNumQuads + 1 > mVertexData.numVertices / 4)
				expand();
			//初始化
			if (mNumQuads == 0)
			{
				
			}


			mSyncRequired = true;
			mNumQuads++;
		}

		public function renderCustom():void
		{
			updateProgram(image.texture, image.tinted, image.smoothing);
			//混合模式
			setBlendFactors(!image.tinted, image.blendMode);
			//投影矩阵
			if(sUpdateCameraMatrix3D)
			{
				sUpdateCameraMatrix3D = false;
				sContext.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 1, sProjectionMatrix3D, true);
			}
			//创建网格
			createVertexBuffer(image.vertexData);
			//xy坐标
			sContext.setVertexBufferAt(0, sVertexBuffer, SVertexData.POSITION_OFFSET, Context3DVertexBufferFormat.FLOAT_2);
			//纹理
			sContext.setTextureAt(0, image.base);
			//uv坐标
			sContext.setVertexBufferAt(2, sVertexBuffer, SVertexData.TEXCOORD_OFFSET, Context3DVertexBufferFormat.FLOAT_2);
			//设置xy
			sPositionMatrix3D.copyFrom(sProjectionMatrix3D);
			sPositionMatrix3D.prependTranslation(image.x,image.y,0);
			//透明度
			setAlpha(image.alpha);
			sContext.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 1, sPositionMatrix3D, true);
			//创建索引，并且提交索引，开始绘制
			createMeshIndexBuffer();
		}

		private function createBuffers() : void
		{
			destroyBuffers();

			var numVertices : int = mVertexData.numVertices;
			var numIndices : int = mIndexData.length;

			if (numVertices == 0)
				return;

			mVertexBuffer = mContext.createVertexBuffer(numVertices, SVertexData.ELEMENTS_PER_VERTEX);
			mVertexBuffer.uploadFromVector(mVertexData.rawData, 0, numVertices);

			mIndexBuffer = mContext.createIndexBuffer(numIndices);
			mIndexBuffer.uploadFromVector(mIndexData, 0, numIndices);

			mSyncRequired = false;
		}

		private function destroyBuffers() : void
		{
			if (mVertexBuffer)
			{
				mVertexBuffer.dispose();
				mVertexBuffer = null;
			}

			if (mIndexBuffer)
			{
				mIndexBuffer.dispose();
				mIndexBuffer = null;
			}
		}

		private function syncBuffers() : void
		{
			if (mVertexBuffer == null)
			{
				createBuffers();
			}
			else
			{
				mVertexBuffer.uploadFromVector(mVertexData.rawData, 0, mVertexData.numVertices);
				mSyncRequired = false;
			}
		}

		public function reset() : void
		{
			mNumQuads = 0;
			mSyncRequired = true;
		}

		private function expand():void
		{
			var oldCapacity:int = this.capacity;
			
			if (oldCapacity >= MAX_NUM_QUADS)
				throw new Error("Exceeded maximum number of quads!");
			
			this.capacity = oldCapacity < 8 ? 16 : oldCapacity * 2;
		}
		
		public function get capacity() : int
		{
			return mVertexData.numVertices / 4;
		}

		public function set capacity(value : int) : void
		{
			var oldCapacity : int = capacity;

			if (value == oldCapacity)
				return;
			else if (value == 0)
				throw new Error("Capacity must be > 0");
			else if (value > MAX_NUM_QUADS)
				value = MAX_NUM_QUADS;
			if (mNumQuads > value)
				mNumQuads = value;

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

		public override function dispose() : void
		{
			destroyBuffers();
			mVertexData.numVertices = 0;
			mIndexData.length = 0;
			mNumQuads = 0;
			super.dispose();
		}
	}
}