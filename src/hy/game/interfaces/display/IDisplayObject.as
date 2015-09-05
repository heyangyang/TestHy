package hy.game.interfaces.display
{


	public interface IDisplayObject extends IDisplayBase
	{
		function removeFromParent(dispose : Boolean = false) : void;
		function setParent(value : IDisplayObjectContainer) : void;
		function render() : void;
	}
}