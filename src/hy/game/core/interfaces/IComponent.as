package hy.game.core.interfaces
{


	public interface IComponent extends IDestroy
	{
		function notifyAdded() : void;
		function notifyRemoved() : void;
		function get type() : *;
	}
}