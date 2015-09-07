package hy.game.interfaces.display
{
	import flash.geom.Rectangle;

	public interface IBitmapData
	{
		function get width() : int;
		function get height() : int;
		function get rect() : Rectangle;
		function getPixel(x : int, y : int) : uint;
		function dispose() : void;
	}
}