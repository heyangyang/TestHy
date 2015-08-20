package hy.game.render
{
	import hy.game.core.interfaces.IContainer;
	import hy.game.core.interfaces.IDisplay;
	import hy.game.stage3D.display.SDisplayObject;
	import hy.game.stage3D.display.SDisplayObjectContainer;

	public class SDirectContainer extends SDisplayObjectContainer implements IContainer
	{
		public function SDirectContainer()
		{
			super();
		}

		public function addGameChildAt(child : IDisplay, index : int) : void
		{
			if (child is SDisplayObject)
			{
				addChildAt(child as SDisplayObject, index);
			}
		}

		public function addGameChild(child : IDisplay) : void
		{
			if (child is SDisplayObject)
			{
				addChild(child as SDisplayObject);
			}
		}

		public function removeGameChildAt(index : int) : void
		{
			this.removeChildAt(index);
		}

		public function getGameChildIndex(child : IDisplay) : int
		{
			return this.getChildIndex(child as SDisplayObject);
		}

		public function setGameChildIndex(child : IDisplay, index : int) : void
		{
			this.setChildIndex(child as SDisplayObject, index);
		}

		public function removeGameChild(child : IDisplay) : void
		{
			this.removeChild(child as SDisplayObject);
		}

		public function get sparent() : IContainer
		{
			return parent as IContainer;
		}
	}
}