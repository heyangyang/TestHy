package hy.game.interfaces.display
{

	public interface IDisplayBase
	{
		function get x() : Number;
		function set x(value : Number) : void;
		function get y() : Number;
		function set y(value : Number) : void;
		function get alpha() : Number;
		function set alpha(value : Number) : void;
		function set scaleX(value : Number) : void;
		function get scaleX() : Number;
		function set scaleY(value : Number) : void;
		function get scaleY() : Number;
		function get width() : Number;
		function set width(value : Number) : void;
		function get height() : Number;
		function set height(value : Number) : void;
		function set rotation(value : Number) : void;
		function get rotation() : Number;
		function set visible(value : Boolean) : void;
		function get visible() : Boolean;
		function get name() : String;
		function set name(value : String) : void;
		function get layer() : int;
		function set layer(value : int) : void;
		function dispose() : void;
	}
}