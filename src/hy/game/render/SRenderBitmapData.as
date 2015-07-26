package hy.game.render
{
	import flash.display.BitmapData;
	
	import hy.game.core.interfaces.IBitmapData;

	public class SRenderBitmapData extends BitmapData implements IBitmapData
	{
		public var name : String;

		public function SRenderBitmapData(width : int, height : int, transparent : Boolean = true, fillColor : uint = 4.294967295E9)
		{
			super(width, height, transparent, fillColor);
		}
	}
}