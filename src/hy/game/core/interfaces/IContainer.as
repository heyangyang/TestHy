package hy.game.core.interfaces
{
	import hy.game.render.SRender;

	public interface IContainer extends IDisplay
	{
		function set tag(value : String) : void;
		function get tag() : String;

		function get numChildren() : int;

		function push(render : SRender) : void;
		function remove(render : SRender) : void;
	}
}