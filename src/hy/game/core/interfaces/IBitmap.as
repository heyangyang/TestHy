package hy.game.core.interfaces
{
	import flash.geom.ColorTransform;
	import flash.geom.Rectangle;

	public interface IBitmap extends IDisplay
	{
		function set data(value : IBitmapData) : void;
		function get data() : IBitmapData;

		function set scaleX(value : Number) : void;
		function get scaleX() : Number;
		function set scaleY(value : Number) : void;
		function get scaleY() : Number;

		function set x(value : Number) : void;
		function get x() : Number;
		function set y(value : Number) : void;
		function get y() : Number;

		function get width() : Number;
		function set width(value : Number) : void;
		function get height() : Number;
		function set height(value : Number) : void;

		function set rotation(value : Number) : void;
		function get rotation() : Number;

		function set visible(value : Boolean) : void;
		function get visible() : Boolean;

		function set alpha(value : Number) : void;
		function get alpha() : Number;

		function set name(value : String) : void;
		function get name() : String;

		function set filters(value : Array) : void;
		function get filters() : Array;

		function removeChild() : void;

		function set colorTransform(value : ColorTransform) : void;
		function get colorTransform() : ColorTransform;

		function get blendMode() : String;
		function set blendMode(value : String) : void;

		function set scrollRect(rect : Rectangle) : void;

		function dispose() : void;
	}
}