package hy.game.stage3D.texture
{
	import flash.geom.Point;
	import flash.utils.Dictionary;

	import hy.game.interfaces.display.IBitmapData;
	import hy.game.data.SRectangle;
	import hy.game.stage3D.utils.cleanMasterString;


	public class STextureAtlas
	{
		protected var mAtlasTexture : STexture;
		protected var mSubTextures : Dictionary;

		public function STextureAtlas(texture : STexture, atlasXml : XML)
		{
			mSubTextures = new Dictionary();
			mAtlasTexture = texture;
			parseAtlasXml(atlasXml);
		}

		public function getAnimationFrame(dir : String, frame : int) : IBitmapData
		{
			return getTexture(dir + "," + frame) as IBitmapData;
		}

		public function getPoint(dir : String, frame : int) : Point
		{
			return SSubTexture(getTexture(dir + "," + frame)).offest;
		}

		protected function parseAtlasXml(atlasXml : XML) : void
		{
			var scale : Number = mAtlasTexture.scale;
			var region : SRectangle;
			var name : String;
			var rx : Number;
			var ry : Number;
			var x : Number;
			var y : Number;
			var width : Number;
			var height : Number;
			var offest : Point;
			for each (var subTexture : XML in atlasXml.SubTexture)
			{
				name = cleanMasterString(subTexture.@name);
				rx = parseFloat(subTexture.@rx) / scale;
				ry = parseFloat(subTexture.@ry) / scale;
				x = parseFloat(subTexture.@x) / scale;
				y = parseFloat(subTexture.@y) / scale;
				width = parseFloat(subTexture.@width) / scale;
				height = parseFloat(subTexture.@height) / scale;
				offest = new Point(rx, ry);
				region = new SRectangle(x, y, width, height);
				addRegion(name, region, offest);
			}
		}

		public function addRegion(name : String, region : SRectangle, offest : Point) : void
		{
			var subTexture : SSubTexture = new SSubTexture(mAtlasTexture, region, offest);
			mSubTextures[name] = subTexture;
		}

		public function removeRegion(name : String) : void
		{
			var subTexture : SSubTexture = mSubTextures[name];
			if (subTexture)
				subTexture.dispose();
			delete mSubTextures[name];
		}

		public function getTexture(name : String) : STexture
		{
			return mSubTextures[name];
		}

		public function get texture() : STexture
		{
			return mAtlasTexture;
		}

		public function dispose() : void
		{
			for each (var subTexture : SSubTexture in mSubTextures)
				subTexture.dispose();
			mSubTextures = null;
			mAtlasTexture.dispose();
		}
	}
}