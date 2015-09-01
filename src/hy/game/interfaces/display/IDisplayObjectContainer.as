package hy.game.interfaces.display
{

	public interface IDisplayObjectContainer extends IDisplayObject
	{
		function removeDisplay(child : IDisplayObject, dispose : Boolean = false) : IDisplayObject;
	}
}