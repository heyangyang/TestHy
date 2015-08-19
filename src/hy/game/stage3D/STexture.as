package hy.game.stage3D
{
	import flash.geom.Rectangle;

	import hy.game.stage3D.utils.SVertexData;

	public class STexture
	{
		public function STexture()
		{
		}

		public function get frame() : Rectangle
		{
			return null;
		}

		public function get width() : int
		{
			return 0;
		}

		public function get height() : int
		{
			return 0;
		}

		public function get premultipliedAlpha() : Boolean
		{
			return false;
		}

		public function adjustVertexData(vertexData : SVertexData) : void
		{

		}

		public function adjustTexCoords(texCoords : Vector.<Number>, startIndex : int = 0, stride : int = 0, count : int = -1) : void
		{

		}
	}
}