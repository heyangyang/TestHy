package hy.game.core.interfaces
{

	public interface IContainer extends IDisplay
	{
		function set x(value : Number) : void;
		function set y(value : Number) : void;
		function get x() : Number;
		function get y() : Number;

		function set scaleX(value : Number) : void;
		function set scaleY(value : Number) : void;
		function get scaleX() : Number;
		function get scaleY() : Number;

		function get numChildren() : int;
		function removeGameChildAt(index : int) : void;
		function removeGameChild(child : IDisplay) : void;
		function addGameChild(child : IDisplay) : void;
		function addGameChildAt(child : IDisplay, index : int) : void;
		function getGameChildIndex(child : IDisplay) : int;
		function setGameChildIndex(child : IDisplay, index : int) : void;
		
		function get sparent() : IContainer;
	}
}