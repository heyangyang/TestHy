package hy.game.interfaces.display
{
	import hy.game.render.SRender;

	public interface IDisplayRenderContainer extends IDisplayRender
	{
		function remove(render : SRender) : void;
	}
}