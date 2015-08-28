package hy.game.stage3D.texture
{
	import flash.display3D.textures.TextureBase;
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	import hy.game.data.SRectangle;
	import hy.game.render.SDirectBitmapData;
	import hy.game.stage3D.utils.SMatrixUtil;
	import hy.game.stage3D.utils.SVertexData;


	public class SSubTexture extends SDirectBitmapData
	{
		/** Helper object. */
		private static var sTexCoords : Point = new Point();
		private static var sMatrix : Matrix = new Matrix();

		private var mParent : STexture;
		private var mRegion : SRectangle;
		private var mOffest : Point;
		private var mTransformationMatrix : Matrix;
		private var mVertexData : SVertexData;

		public function SSubTexture(parent : STexture, region : SRectangle, offest : Point = null)
		{
			super();
			mParent = parent;
			mRegion = region;
			mOffest = offest;
			mTransformationMatrix = new Matrix();
			mTransformationMatrix.scale(mRegion.width / mParent.width, mRegion.height / mParent.height);
			mTransformationMatrix.translate(mRegion.x / mParent.width, mRegion.y / mParent.height);
			mVertexData = new SVertexData(4);
			mVertexData.setTexCoords(0, 0.0, 0.0);
			mVertexData.setTexCoords(1, 1.0, 0.0);
			mVertexData.setTexCoords(2, 0.0, 1.0);
			mVertexData.setTexCoords(3, 1.0, 1.0);
			mVertexData.setPosition(0, 0.0, 0.0);
			mVertexData.setPosition(1, mRegion.width, 0.0);
			mVertexData.setPosition(2, 0.0, mRegion.height);
			mVertexData.setPosition(3, mRegion.width, mRegion.height);
			adjustVertexData(mVertexData);
		}

		public override function adjustVertexData(vertexData : SVertexData) : void
		{
			var startIndex : int = SVertexData.TEXCOORD_OFFSET;
			var stride : int = SVertexData.ELEMENTS_PER_VERTEX - 2;
			adjustTexCoords(vertexData.rawData, startIndex, stride, 4);
		}

		public override function adjustTexCoords(texCoords : Vector.<Number>, startIndex : int = 0, stride : int = 0, count : int = -1) : void
		{
			var endIndex : int = startIndex + count * (2 + stride);
			var u : Number, v : Number;

			sMatrix.identity();
			sMatrix.concat(mTransformationMatrix);

			for (var i : int = startIndex; i < endIndex; i += 2 + stride)
			{
				u = texCoords[i];
				v = texCoords[int(i + 1)];

				SMatrixUtil.transformCoords(sMatrix, u, v, sTexCoords);

				texCoords[i] = sTexCoords.x;
				texCoords[int(i + 1)] = sTexCoords.y;
			}
		}

		public override function get vertexData() : SVertexData
		{
			return mVertexData;
		}

		public function get offest() : Point
		{
			return mOffest;
		}

		public override function get width() : int
		{
			return mRegion.width;
		}

		public override function get height() : int
		{
			return mRegion.height;
		}

		public override function get scale() : Number
		{
			return mParent.scale;
		}

		public override function get mipMapping() : Boolean
		{
			return mParent.mipMapping;
		}

		public override function get format() : String
		{
			return mParent.format;
		}

		public override function get base() : TextureBase
		{
			return mParent.base;
		}

		public override function get root() : SConcreteTexture
		{
			return mParent.root;
		}

		public override function dispose() : void
		{
			super.dispose();
			mParent = null;
			mRegion = null;
			mOffest = null;
			mTransformationMatrix = null;
			mVertexData = null;
		}
	}
}