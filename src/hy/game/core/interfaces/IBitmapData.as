package hy.game.core.interfaces
{
	import flash.geom.Rectangle;

	public interface IBitmapData
	{
		function dispose() : void;
		function get width() : int;
		function get height() : int;
		function get rect() : Rectangle;
		function getPixel(x : int, y : int) : uint;
	}
}