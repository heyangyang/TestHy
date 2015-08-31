package hy.game.stage3D.display
{
	import hy.game.core.event.SEvent;
	import hy.game.stage3D.interfaces.IDisplayObject;
	import hy.game.stage3D.interfaces.IDisplayObjectContainer;


	public class SDisplayObjectContainer extends SDisplayObject implements IDisplayObjectContainer
	{
		protected var mChildren : Vector.<IDisplayObject>;
		protected var mNumChildren : int;

		public function SDisplayObjectContainer()
		{
			super();
			mNumChildren = 0;
			mChildren = new Vector.<IDisplayObject>();
		}

		public function addChild(child : IDisplayObject) : IDisplayObject
		{
			return addChildAt(child, mChildren.length);
		}

		public function addChildAt(child : IDisplayObject, index : int) : IDisplayObject
		{
			if (index >= 0 && index <= mNumChildren)
			{
				if (child.parent == this)
				{
					setChildIndex(child, index);
				}
				else
				{
					child.removeFromParent();
					if (index == numChildren)
						mChildren[numChildren] = child;
					else
						spliceChildren(index, 0, child);
					mNumChildren++;
					child.setParent(this);
					child.dispatchEventWith(SEvent.ADDED, true);
				}
				return child;
			}
			else
			{
				throw new RangeError("Invalid child index");
			}
		}

		public function removeChild(child : IDisplayObject, dispose : Boolean = false) : IDisplayObject
		{
			var childIndex : int = getChildIndex(child);
			if (childIndex != -1)
				removeChildAt(childIndex, dispose);
			return child;
		}

		public function removeChildAt(index : int, dispose : Boolean = false) : IDisplayObject
		{
			if (index >= 0 && index < mChildren.length)
			{
				mNumChildren--;
				var child : IDisplayObject = mChildren[index];
				child.dispatchEventWith(SEvent.REMOVED, true);
				child.setParent(null);
				index = mChildren.indexOf(child);
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

		public function removeChildren(beginIndex : int = 0, endIndex : int = -1, dispose : Boolean = false) : void
		{
			if (endIndex < 0 || endIndex >= numChildren)
				endIndex = numChildren - 1;

			for (var i : int = beginIndex; i <= endIndex; ++i)
				removeChildAt(beginIndex, dispose);
		}

		public function getChildAt(index : int) : IDisplayObject
		{
			var numChildren : int = mChildren.length;

			if (index < 0)
				index = numChildren + index;

			if (index >= 0 && index < numChildren)
				return mChildren[index];
			else
				throw new RangeError("Invalid child index");
		}

		public function getChildByName(name : String) : IDisplayObject
		{
			var numChildren : int = mChildren.length;
			for (var i : int = 0; i < numChildren; ++i)
				if (mChildren[i].name == name)
					return mChildren[i];

			return null;
		}

		public function getChildIndex(child : IDisplayObject) : int
		{
			return mChildren.indexOf(child);
		}

		public function setChildIndex(child : IDisplayObject, index : int) : void
		{
			var oldIndex : int = getChildIndex(child);
			if (oldIndex == index)
				return;
			if (oldIndex == -1)
				throw new ArgumentError("Not a child of this container");
			spliceChildren(oldIndex, 1);
			spliceChildren(index, 0, child);
		}

		public function swapChildren(child1 : IDisplayObject, child2 : IDisplayObject) : void
		{
			var index1 : int = getChildIndex(child1);
			var index2 : int = getChildIndex(child2);
			if (index1 == -1 || index2 == -1)
				throw new ArgumentError("Not a child of this container");
			swapChildrenAt(index1, index2);
		}

		public function swapChildrenAt(index1 : int, index2 : int) : void
		{
			var child1 : IDisplayObject = getChildAt(index1);
			var child2 : IDisplayObject = getChildAt(index2);
			mChildren[index1] = child2;
			mChildren[index2] = child1;
		}

		public function contains(child : IDisplayObject) : Boolean
		{
			while (child)
			{
				if (child == this)
					return true;
				else
					child = child.parent;
			}
			return false;
		}

		protected function spliceChildren(startIndex : int, deleteCount : uint = uint.MAX_VALUE, insertee : IDisplayObject = null) : void
		{
			var vector : Vector.<IDisplayObject> = mChildren;
			var oldLength : uint = vector.length;

			if (startIndex < 0)
				startIndex += oldLength;
			if (startIndex < 0)
				startIndex = 0;
			else if (startIndex > oldLength)
				startIndex = oldLength;
			if (startIndex + deleteCount > oldLength)
				deleteCount = oldLength - startIndex;

			var i : int;
			var insertCount : int = insertee ? 1 : 0;
			var deltaLength : int = insertCount - deleteCount;
			var newLength : uint = oldLength + deltaLength;
			var shiftCount : int = oldLength - startIndex - deleteCount;

			if (deltaLength < 0)
			{
				i = startIndex + insertCount;
				while (shiftCount)
				{
					vector[i] = vector[int(i - deltaLength)];
					--shiftCount;
					++i;
				}
				vector.length = newLength;
			}
			else if (deltaLength > 0)
			{
				i = 1;
				while (shiftCount)
				{
					vector[int(newLength - i)] = vector[int(oldLength - i)];
					--shiftCount;
					++i;
				}
				vector.length = newLength;
			}

			if (insertee)
				vector[startIndex] = insertee;
		}

		public function get numChildren() : int
		{
			return mNumChildren;
		}

		public override function render() : void
		{
			for (var i : int = 0; i < mNumChildren; ++i)
			{
				mChildren[i].render();
			}
		}

		public override function dispose() : void
		{
			for (var i : int = mNumChildren - 1; i >= 0; --i)
				mChildren[i].dispose();
			if (mChildren)
			{
				mChildren.length = 0;
				mChildren = null;
			}
			mNumChildren = 0;
			super.dispose();
		}

	}
}