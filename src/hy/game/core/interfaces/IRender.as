package hy.game.core.interfaces
{
	import flash.geom.ColorTransform;

	public interface IRender extends IDisplay
	{
		function get name() : String;
		function set name(value : String) : void;

		function notifyAddedToRender() : void;
		function notifyRemovedFromRender() : void;

		function addChild(child : IRender) : IRender;
		function addChildAt(child : IRender, index : int) : IRender;
		function removeChild(child : IRender) : IRender;
		function removeChildAt(index : int) : IRender;
		function getChildAt(index : int) : IRender;
		function getChildIndex(child : IRender) : int;
		function getChildByName(name : String) : IRender;
		function removeAllChildren() : void;

		function get numChildren() : int;

		function get parent() : IRender;
		function set parent(value : IRender) : void;

		function get zDepth() : int;

		function get layer() : int;
		function set layer(value : int) : void;

		function get index() : int;
		function set index(value : int) : void;

		function get needLayerSort() : Boolean;
		function set needLayerSort(value : Boolean) : void;
		function onLayerSort() : void;

		function rotate(rotate : Number) : void;

		function get x() : Number;
		function set x(value : Number) : void;

		function get y() : Number;
		function set y(value : Number) : void;

		function get width() : Number;
		function get height() : Number;

		function get scaleX() : Number;
		function set scaleX(value : Number) : void;

		function get scaleY() : Number;
		function set scaleY(value : Number) : void;

		function get alpha() : Number;
		function set alpha(value : Number) : void;

		function get filters() : Array;
		function set filters(value : Array) : void;

		function get rotation() : Number;
		function set rotation(value : Number) : void;

		function get blendMode() : String;
		function set blendMode(value : String) : void;

		function get colorTransform() : ColorTransform;
		function set colorTransform(value : ColorTransform) : void;

		function get visible() : Boolean;
		function set visible(value : Boolean) : void;

		function get render() : IBitmap;

		function set container(value : IGameContainer) : void;

		function set bitmapData(value : IBitmapData) : void;
		function get bitmapData() : IBitmapData;

		function dispose() : void;
	}
}