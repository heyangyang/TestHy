package starling.base
{
	import starling.core.starling_internal;
	import starling.display.DisplayObject;
	import starling.display.Sprite;

	use namespace starling_internal;

	public class SSprite extends Sprite
	{
		public function SSprite()
		{
			super();
		}

		override public function addChildAt(child : DisplayObject, index : int) : DisplayObject
		{
			var numChildren : int=mChildren.length;

			if (index >= 0 && index <= numChildren)
			{
				if (child.parent == this)
				{
					setChildIndex(child, index); // avoids dispatching events
				}
				else
				{
					child.removeFromParent();

					if (index == numChildren)
						mChildren[numChildren]=child;
					else
						spliceChildren(index, 0, child);

					child.setParent(this);

						//child.dispatchEventWith(Event.ADDED, true);

//					if (stage)
//					{
//						var container : DisplayObjectContainer=child as DisplayObjectContainer;
//						if (container)
//							container.broadcastEventWith(Event.ADDED_TO_STAGE);
//						else
//							child.dispatchEventWith(Event.ADDED_TO_STAGE);
//					}
				}

				return child;
			}
			else
			{
				throw new RangeError("Invalid child index");
			}
		}


		override public function removeChildAt(index : int, dispose : Boolean=false) : DisplayObject
		{
			if (index >= 0 && index < mChildren.length)
			{
				var child : DisplayObject=mChildren[index];
//				child.dispatchEventWith(Event.REMOVED, true);

//				if (stage)
//				{
//					var container : DisplayObjectContainer=child as DisplayObjectContainer;
//					if (container)
//						container.broadcastEventWith(Event.REMOVED_FROM_STAGE);
//					else
//						child.dispatchEventWith(Event.REMOVED_FROM_STAGE);
//				}

				child.setParent(null);
				index=mChildren.indexOf(child); // index might have changed by event handler
				if (index >= 0)
					spliceChildren(index, 1);
				if (dispose)
					child.dispose();

				return child;
			}
			else
			{
				throw new RangeError("Invalid child index");
			}
		}
	}
}