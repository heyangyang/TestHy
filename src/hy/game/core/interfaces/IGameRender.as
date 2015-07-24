package hy.game.core.interfaces
{
	import flash.geom.ColorTransform;

	public interface IGameRender
	{
		function get name() : String;
		function set name(value : String) : void;

		function notifyAddedToRender() : void;
		function notifyRemovedFromRender() : void;

		function addChild(child : IGameRender) : IGameRender;
		function addChildAt(child : IGameRender, index : int) : IGameRender;
		function removeChild(child : IGameRender) : IGameRender;
		function removeChildAt(index : int) : IGameRender;
		function getChildAt(index : int) : IGameRender;
		function getChildIndex(child : IGameRender) : int;
		function getChildByName(name : String) : IGameRender;
		function removeAllChildren() : void;

		function get numChildren() : int;

		function get parent() : IGameRender;
		function set parent(value : IGameRender) : void;

		function get zDepth() : int;

		function get layer() : int;
		function set layer(value : int) : void;

		function rotate(rotate : Number) : void;

		function get x() : Number;
		function set x(value : Number) : void;

		function get y() : Number;
		function set y(value : Number) : void;

		function get width() : Number;
		function get height() : Number;

		function get scale() : Number;
		function set scale(value : Number) : void;

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

		function dispose() : void;
	}
}