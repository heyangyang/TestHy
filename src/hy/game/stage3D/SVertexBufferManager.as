package hy.game.stage3D
{
	import flash.display3D.VertexBuffer3D;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.utils.Dictionary;

	import hy.game.data.SRectangle;
	import hy.game.stage3D.texture.STexture;
	import hy.game.stage3D.utils.SMatrixUtil;
	import hy.game.stage3D.utils.SVertexBuffer3D;
	import hy.game.stage3D.utils.SVertexData;

	/**
	 * 顶点管理器
	 * @author hyy
	 *
	 */
	public class SVertexBufferManager
	{
		private static var sVertexDictionary : Dictionary = new Dictionary();
		private static var sVertexSubDictionary : Dictionary = new Dictionary();
		private static var sTexCoords : Point = new Point();
		private static var sMatrix : Matrix = new Matrix();
		private static var sVertexCount : int = 0;

		public static function get vertexCount() : int
		{
			return sVertexCount;
		}

		public static function createVertexBuffer3D(width : int, height : int) : SVertexBuffer3D
		{
			//根据宽高计算出的唯一key
			var key : int = (width << 8) | height;
			var tVertexBuffer3D : SVertexBuffer3D = sVertexDictionary[key];
			if (tVertexBuffer3D)
			{
				tVertexBuffer3D.retain();
				return tVertexBuffer3D;
			}
			var tVertexData : SVertexData = new SVertexData(4);
			tVertexData.setTexCoords(0, 0.0, 0.0);
			tVertexData.setTexCoords(1, 1.0, 0.0);
			tVertexData.setTexCoords(2, 0.0, 1.0);
			tVertexData.setTexCoords(3, 1.0, 1.0);
			tVertexData.setPosition(0, 0.0, 0.0);
			tVertexData.setPosition(1, width, 0.0);
			tVertexData.setPosition(2, 0.0, height);
			tVertexData.setPosition(3, width, height);
			var tBuffer3D : VertexBuffer3D = SStage3D.context.createVertexBuffer(tVertexData.numVertices, SVertexData.ELEMENTS_PER_VERTEX);
			tBuffer3D.uploadFromVector(tVertexData.rawData, 0, tVertexData.numVertices);
			tVertexBuffer3D = new SVertexBuffer3D();
			tVertexBuffer3D.data = tBuffer3D;
			sVertexDictionary[key] = tVertexBuffer3D;
			sVertexCount++;
			return tVertexBuffer3D;
		}

		public static function createSubVertexBuffer3D(region : SRectangle, parent : STexture, scaleX : Number = 1.0, scaleY : Number = 1.0, rotation : Number = 0.0) : SVertexBuffer3D
		{
			var key : String = region.toString() + "," + parent.width + "," + parent.height + "," + scaleX + "," + scaleY + "," + rotation;
			var tVertexBuffer3D : SVertexBuffer3D = sVertexSubDictionary[key];
			if (tVertexBuffer3D)
			{
				tVertexBuffer3D.retain();
				return tVertexBuffer3D;
			}
			sMatrix.identity();
			sMatrix.scale(region.width / parent.width, region.height / parent.height);
			sMatrix.translate(region.x / parent.width, region.y / parent.height);
			var tVertexData : SVertexData = new SVertexData(4);
			tVertexData.setTexCoords(0, 0.0, 0.0);
			tVertexData.setTexCoords(1, 1.0, 0.0);
			tVertexData.setTexCoords(2, 0.0, 1.0);
			tVertexData.setTexCoords(3, 1.0, 1.0);
			tVertexData.setPosition(0, 0.0, 0.0);
			tVertexData.setPosition(1, region.width, 0.0);
			tVertexData.setPosition(2, 0.0, region.height);
			tVertexData.setPosition(3, region.width, region.height);
			adjustVertexData(tVertexData);

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
			var sNewData : SVertexData = new SVertexData(4);
			tVertexData.copyTransformedTo(sNewData, 0, sMatrix, 0, 4);
			var tBuffer3D : VertexBuffer3D = SStage3D.context.createVertexBuffer(sNewData.numVertices, SVertexData.ELEMENTS_PER_VERTEX);
			tBuffer3D.uploadFromVector(sNewData.rawData, 0, sNewData.numVertices);
			tVertexBuffer3D = new SVertexBuffer3D();
			tVertexBuffer3D.data = tBuffer3D;
			sVertexSubDictionary[key] = tVertexBuffer3D;
			sVertexCount++;
			return tVertexBuffer3D;
		}

		private static function adjustVertexData(vertexData : SVertexData) : void
		{
			var startIndex : int = SVertexData.TEXCOORD_OFFSET;
			var stride : int = SVertexData.ELEMENTS_PER_VERTEX - 2;
			adjustTexCoords(vertexData.rawData, startIndex, stride, 4);
		}

		private static function adjustTexCoords(texCoords : Vector.<Number>, startIndex : int = 0, stride : int = 0, count : int = -1) : void
		{
			var endIndex : int = startIndex + count * (2 + stride);
			var u : Number, v : Number;

			for (var i : int = startIndex; i < endIndex; i += 2 + stride)
			{
				u = texCoords[i];
				v = texCoords[int(i + 1)];

				SMatrixUtil.transformCoords(sMatrix, u, v, sTexCoords);

				texCoords[i] = sTexCoords.x;
				texCoords[int(i + 1)] = sTexCoords.y;
			}
		}
	}
}