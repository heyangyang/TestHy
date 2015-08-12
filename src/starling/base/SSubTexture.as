package starling.base
{
	import flash.geom.Point;
	import flash.geom.Rectangle;

	import starling.textures.SubTexture;
	import starling.textures.Texture;

	public class SSubTexture extends SubTexture
	{
		public var offest : Point;

		public function SSubTexture(parent : Texture, region : Rectangle = null, ownsParent : Boolean = false, frame : Rectangle = null, rotated : Boolean = false)
		{
			super(parent, region, ownsParent, frame, rotated);
		}
	}
}