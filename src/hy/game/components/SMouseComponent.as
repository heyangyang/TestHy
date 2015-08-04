package hy.game.components
{
	import hy.game.core.Component;
	import hy.game.manager.SMouseMangaer;

	/**
	 * 鼠标事件组件
	 * @author hyy
	 *
	 */
	public class SMouseComponent extends Component
	{
		public function SMouseComponent(type : * = null)
		{
			super(type);
		}

		override public function notifyAdded() : void
		{
			SMouseMangaer.addComponent(this);
		}

		override public function notifyRemoved() : void
		{
			SMouseMangaer.removeComponent(this);
		}

		public function checkIsMouseIn(mouseX : int, mouseY : int) : Boolean
		{
			return false;
		}
	}
}