package hy.game.stage3D.interfaces
{


	public interface IDisplayObject
	{
		function get x() : Number;
		function set x(value : Number) : void;
		function get y() : Number;
		function set y(value : Number) : void;
		function get alpha() : Number;
		function set alpha(value : Number) : void;
		function get index() : int;
		
		function get parent() : IDisplayObjectContainer;
		function removeFromParent(dispose : Boolean = false) : void;
		function setParent(value : IDisplayObjectContainer) : void;
		function dispatchEventWith(type : String, data : Object = null) : void;
		function render() : void;
		function dispose() : void;
	}
}