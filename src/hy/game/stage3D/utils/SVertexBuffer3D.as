package hy.game.stage3D.utils
{
	import flash.display3D.VertexBuffer3D;

	import hy.game.core.SReference;

	public class SVertexBuffer3D extends SReference
	{
		private var mVertexBuffer3D : VertexBuffer3D

		public function SVertexBuffer3D()
		{
			super();
		}

		public function get data() : VertexBuffer3D
		{
			return mVertexBuffer3D;
		}

		public function set data(value : VertexBuffer3D) : void
		{
			mVertexBuffer3D = value;
		}

		protected override function dispose() : void
		{
			super.dispose();
			mVertexBuffer3D && mVertexBuffer3D.dispose();
		}
	}
}