package hy.game.core.interfaces
{
	import hy.game.stage3D.interfaces.IDisplayObjectContainer;

	public interface IRender extends IDisplayObjectContainer
	{
		function notifyAddedToRender() : void;
		function notifyRemovedFromRender() : void;
		function sort2Push(render : IRender) : void;
		function get zDepth() : int;
		function get layer() : int;
		function get name() : String;
	}
}