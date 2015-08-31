package hy.game.stage3D.interfaces
{

	public interface IDisplayObjectContainer extends IDisplayObject
	{
		function removeChild(child : IDisplayObject, dispose : Boolean = false) : IDisplayObject;
	}
}