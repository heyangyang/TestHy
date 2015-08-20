package hy.game.stage3D.display
{
	import hy.game.core.event.SEvent;
	import hy.game.namespaces.name_part;

	use namespace name_part;

	public class SDisplayObjectContainer extends SDisplayObject
	{
		protected var mChildren : Vector.<SDisplayObject>;
		protected var mNumChildren : int;

		public function SDisplayObjectContainer()
		{
			super();
			mNumChildren = 0;
			mChildren = new Vector.<SDisplayObject>();
		}

		public function addChild(child : SDisplayObject) : SDisplayObject
		{
			return addChildAt(child, mNumChildren);
		}

		public function addChildAt(child : SDisplayObject, index : int) : SDisplayObject
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
					if (index >= mNumChildren)
						mChildren[mNumChildren] = child;
					else
						mChildren.splice(index, 0, child);
					mNumChildren++;
					child.mIndex = index;
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

		public function removeChild(child : SDisplayObject, dispose : Boolean = false) : SDisplayObject
		{
			var childIndex : int = getChildIndex(child);
			if (childIndex != -1)
				removeChildAt(childIndex, dispose);
			return child;
		}

		public function removeChildAt(index : int, dispose : Boolean = false) : SDisplayObject
		{
			if (index >= 0 && index < mChildren.length)
			{
				var child : SDisplayObject = mChildren[index];
				child.dispatchEventWith(SEvent.REMOVED, true);
				child.setParent(null);
				index = child.mIndex;
				if (index >= 0)
				{
					mNumChildren--;
					mChildren.splice(index, 1);
				}
				if (dispose)
					child.dispose();
				return child;
			}
//			else
//			{
//				throw new RangeError("Invalid child index");
//			}
			return null;
		}

		public function removeChildren(beginIndex : int = 0, endIndex : int = -1, dispose : Boolean = false) : void
		{
			if (endIndex < 0 || endIndex >= mNumChildren)
				endIndex = mNumChildren - 1;

			for (var i : int = beginIndex; i <= endIndex; ++i)
				removeChildAt(beginIndex, dispose);
		}

		public function getChildAt(index : int) : SDisplayObject
		{
			if (index < 0)
				index = mNumChildren + index;

			if (index >= 0 && index < mNumChildren)
				return mChildren[index];
			else
				throw new RangeError("Invalid child index");
		}

		public function getChildByName(name : String) : SDisplayObject
		{
			for (var i : int = 0; i < mNumChildren; ++i)
				if (mChildren[i].name == name)
					return mChildren[i];

			return null;
		}

		public function getChildIndex(child : SDisplayObject) : int
		{
			return child.mIndex;
		}

		public function setChildIndex(child : SDisplayObject, index : int) : void
		{
			var oldIndex : int = getChildIndex(child);
			if (oldIndex == index)
				return;
			if (oldIndex == -1)
				throw new ArgumentError("Not a child of this container");
			mChildren.splice(oldIndex, 1);
			mChildren.splice(index, 0, child);
			child.mIndex = index;
		}

		public function contains(child : SDisplayObject) : Boolean
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
			mNumChildren = 0;
			super.dispose();
		}

	}
}