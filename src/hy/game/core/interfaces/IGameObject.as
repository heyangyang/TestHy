package hy.game.core.interfaces
{
	import hy.game.core.Component;
	import hy.game.data.STransform;
	import hy.game.render.SRender;

	public interface IGameObject
	{
		function get transform() : STransform;

		function set name(value : String) : void;
		function get name() : String;

		function set tag(value : String) : void;
		function get tag() : String;

		function addRender(render : SRender) : void;
		function removeRender(render : SRender) : void;

		function addComponent(com : Component) : void;

		function removeComponent(com : Component) : void;
		function removeComponentByType(type : *) : void;

		function getComponentByType(type : *) : Component;
	}
}