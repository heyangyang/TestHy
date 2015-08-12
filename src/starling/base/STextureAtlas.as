package starling.base
{
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import hy.game.core.interfaces.IBitmapData;
	
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;
	import starling.utils.cleanMasterString;

	public class STextureAtlas extends TextureAtlas
	{
		public function STextureAtlas(texture : Texture, atlasXml : XML = null)
		{
			super(texture, atlasXml);
		}

		public function getAnimationFrame(name : String, dir : String, frame : int) : IBitmapData
		{
			return getTexture(name + "," + dir + "," + frame) as IBitmapData;
		}

		public function getPoint(name : String, dir : String, frame : int) : Point
		{
			return SSubTexture(getTexture(name + "," + dir + "," + frame)).offest;
		}

		/** This function is called by the constructor and will parse an XML in Starling's
		 *  default atlas file format. Override this method to create custom parsing logic
		 *  (e.g. to support a different file format). */
		override protected function parseAtlasXml(atlasXml : XML) : void
		{
			var scale : Number = mAtlasTexture.scale;
			var region : Rectangle = new Rectangle();
			var frame : Rectangle = new Rectangle();

			for each (var subTexture : XML in atlasXml.SubTexture)
			{
				var name : String = cleanMasterString(subTexture.@name);
				var rx : Number = parseFloat(subTexture.@rx) / scale;
				var ry : Number = parseFloat(subTexture.@ry) / scale;
				var x : Number = parseFloat(subTexture.@x) / scale;
				var y : Number = parseFloat(subTexture.@y) / scale;
				var width : Number = parseFloat(subTexture.@width) / scale;
				var height : Number = parseFloat(subTexture.@height) / scale;
				var frameX : Number = parseFloat(subTexture.@frameX) / scale;
				var frameY : Number = parseFloat(subTexture.@frameY) / scale;
				var frameWidth : Number = parseFloat(subTexture.@frameWidth) / scale;
				var frameHeight : Number = parseFloat(subTexture.@frameHeight) / scale;
				var rotated : Boolean = parseBool(subTexture.@rotated);
				var offest : Point = new Point(rx, ry);
				region.setTo(x, y, width, height);
				frame.setTo(frameX, frameY, frameWidth, frameHeight);

				if (frameWidth > 0 && frameHeight > 0)
					addNewRegion(name, region, offest, frame, rotated);
				else
					addNewRegion(name, region, offest, null, rotated);
			}
		}

		public function addNewRegion(name : String, region : Rectangle, offest : Point, frame : Rectangle = null, rotated : Boolean = false) : void
		{
			var subTexture : SSubTexture = new SSubTexture(mAtlasTexture, region, false, frame, rotated);
			subTexture.offest = offest;
			mSubTextures[name] = subTexture;
			mSubTextureNames = null;
		}
	}
}