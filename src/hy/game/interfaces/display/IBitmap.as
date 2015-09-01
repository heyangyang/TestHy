package hy.game.interfaces.display
{
	import flash.geom.ColorTransform;
	import flash.geom.Rectangle;

	public interface IBitmap extends IDisplayBase
	{
		function render() : void;
			
		function set data(value : IBitmapData) : void;
		function get data() : IBitmapData;

		function set filters(value : Array) : void;
		function get filters() : Array;

		function removeFromParent(dispose : Boolean = false) : void;

		function set colorTransform(value : ColorTransform) : void;
		function get colorTransform() : ColorTransform;

		function get blendMode() : String;
		function set blendMode(value : String) : void;

		function set scrollRect(rect : Rectangle) : void;

		function set dropShadow(value : Boolean) : void;
	}
}