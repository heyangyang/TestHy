package hy.game.interfaces.component
{
	import hy.game.interfaces.core.IDispose;


	public interface IComponent extends IDispose
	{
		function notifyAdded() : void;
		function notifyRemoved() : void;
		function get type() : *;
	}
}