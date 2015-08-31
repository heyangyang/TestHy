package hy.game.core.interfaces
{
	import hy.game.core.GameObject;
	import hy.game.render.SRender;

	public interface IGameContainer
	{
		function set tag(value : String) : void;
		function set priority(value : int) : void;
		function get priority() : int;

		function addObject(object : GameObject) : void;
		function removeObject(object : GameObject) : void;

		function addChildRender(render : SRender, index : int) : void;
		function addRender(render : SRender) : void;
		function removeRender(render : SRender) : void;
		function getRenderIndex(render : SRender) : int;

		function changePrioritySort() : void;
		function changeDepthSort() : void;

		function update() : void;

		function get container() : IContainer;
	}
}