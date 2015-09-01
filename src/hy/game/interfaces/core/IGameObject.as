package hy.game.interfaces.core
{
	import hy.game.core.Component;
	import hy.game.data.STransform;

	public interface IGameObject
	{
		function get transform() : STransform;

		function set name(value : String) : void;
		function get name() : String;

		function set tag(value : String) : void;
		function get tag() : String;

		function addComponent(com : Component, priority : int = 0) : void;

		function removeComponent(com : Component) : void;
		function removeComponentByType(type : *) : void;

		function getComponentByType(type : *) : Component;
	}
}