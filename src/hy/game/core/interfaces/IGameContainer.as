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

		function addChildRender(render : IGameRender, index : int) : void;
		function addContainer(container : IContainer, index : int) : void;

		function addRender(render : IGameRender) : void;
		function removeRender(render : IGameRender) : void;
		function getRenderIndex(render : IGameRender) : int;

		function changePrioritySort() : void;
		function changeDepthSort() : void;

		function update() : void;
	}
}