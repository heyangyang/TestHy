package hy.game.core.interfaces
{
	import hy.game.core.GameObject;

	public interface IGameContainer
	{
		function set tag(value : String) : void;
		function set priority(value : int) : void;
		function get priority() : int;

		function get numChildren() : int;

		function addObject(object : GameObject) : void;
		function removeObject(object : GameObject) : void;

		function addChildRender(render : IRender, index : int) : void;
		function addContainer(container : IContainer, index : int) : void;
		function removeContainer(container : IContainer) : void;

		function addRender(render : IRender) : void;
		function removeRender(render : IRender) : void;
		function getRenderIndex(render : IRender) : int;

		function changePrioritySort() : void;
		function changeDepthSort() : void;

		function update() : void;
	}
}