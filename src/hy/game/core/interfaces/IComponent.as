package hy.game.core.interfaces
{


	public interface IComponent extends IDispose
	{
		function notifyAdded() : void;
		function notifyRemoved() : void;
		function get type() : *;
	}
}