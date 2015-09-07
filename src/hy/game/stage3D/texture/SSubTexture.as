package hy.game.stage3D.texture
{
	import flash.display3D.textures.TextureBase;
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	import hy.game.data.SRectangle;
	import hy.game.render.SDirectBitmapData;
	import hy.game.stage3D.SVertexBufferManager;
	import hy.game.stage3D.utils.SVertexBuffer3D;


	public class SSubTexture extends SDirectBitmapData
	{
		/** Helper object. */
		private static var sTexCoords : Point = new Point();
		private static var sMatrix : Matrix = new Matrix();

		private var mParent : STexture;
		private var mRegion : SRectangle;
		private var mOffest : Point;
		private var mVertexBuffer3D : SVertexBuffer3D;

		public function SSubTexture(parent : STexture, region : SRectangle, offest : Point = null)
		{
			super();
			mParent = parent;
			mRegion = region;
			mOffest = offest;
			mVertexBuffer3D = SVertexBufferManager.createSubVertexBuffer3D(mRegion, mParent);
		}

		public override function get vertexBufferData() : SVertexBuffer3D
		{
			return mVertexBuffer3D;
		}

		public override function updateVertexBuffer3D(scaleX : Number = 1.0, scaleY : Number = 1.0, rotation : Number = 0.0) : SVertexBuffer3D
		{
			return SVertexBufferManager.createSubVertexBuffer3D(mRegion, mParent, scaleX, scaleY, rotation);
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
			mVertexBuffer3D && mVertexBuffer3D.release();
			mVertexBuffer3D = null;
			mParent = null;
			mRegion = null;
			mOffest = null;
		}
	}
}