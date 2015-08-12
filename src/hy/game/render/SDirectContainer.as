package hy.game.render
{
	import hy.game.core.interfaces.IContainer;
	import hy.game.core.interfaces.IDisplay;
	
	import starling.base.SSprite;
	import starling.display.DisplayObject;

	public class SDirectContainer extends SSprite implements IContainer
	{
		public function SDirectContainer()
		{
			super();
		}

		public function addGameChildAt(child : IDisplay, index : int) : void
		{
			if (child is DisplayObject)
			{
				addChildAt(child as DisplayObject, index);
			}
		}

		public function addGameChild(child : IDisplay) : void
		{
			if (child is DisplayObject)
			{
				addChild(child as DisplayObject);
			}
		}

		public function removeGameChildAt(index : int) : void
		{
			this.removeChildAt(index);
		}

		public function getGameChildIndex(child : IDisplay) : int
		{
			return this.getChildIndex(child as DisplayObject);
		}

		public function setGameChildIndex(child : IDisplay, index : int) : void
		{
			this.setChildIndex(child as DisplayObject, index);
		}

		public function removeGameChild(child : IDisplay) : void
		{
			this.removeChild(child as DisplayObject);
		}

		public function get sparent() : IContainer
		{
			return parent as IContainer;
		}
	}
}