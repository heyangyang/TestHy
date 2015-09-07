package hy.game.interfaces.display
{
	

	public interface IBitmap extends IDisplayObject
	{
		function get depth() : int;
		function set depth(value : int) : void;

		function set data(value : IBitmapData) : void;
		function get data() : IBitmapData;

		function set colorFilter(value : *) : void;
		function get colorFilter() : *;

		function get blendMode() : String;
		function set blendMode(value : String) : void;

	}
}