package hy.game.interfaces.display
{
	import flash.geom.ColorTransform;

	public interface IBitmap extends IDisplayObject
	{
		function get depth() : int;
		function set depth(value : int) : void;

		function set data(value : IBitmapData) : void;
		function get data() : IBitmapData;

		function set filters(value : Array) : void;
		function get filters() : Array;

		function set colorTransform(value : ColorTransform) : void;
		function get colorTransform() : ColorTransform;

		function get blendMode() : String;
		function set blendMode(value : String) : void;

	}
}