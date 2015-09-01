package hy.game.manager
{
	import hy.game.interfaces.core.IEnterFrame;
	import hy.game.interfaces.core.IUpdate;

	public class SUpdateManager extends SBaseManager implements IEnterFrame
	{
		private static var instance : SUpdateManager;

		public static function getInstance() : SUpdateManager
		{
			if (instance == null)
				instance = new SUpdateManager();
			return instance;
		}

		private var mUpdatables : Vector.<IUpdate> = new Vector.<IUpdate>();
		private var mPrioritySort : Boolean;
		private var mNumber : int;
		private var mUpdate : IUpdate;

		public function SUpdateManager()
		{
			if (instance)
				error("instance != null");
		}

		public function update() : void
		{
			mPrioritySort && onSort();
			for (var i : int = mNumber - 1; i >= 0; i--)
			{
				mUpdate = mUpdatables[i];
				if (mUpdate.isDispose || !mUpdate.checkUpdatable())
					continue;
				mUpdate.update();
			}
		}

		public function register(update : IUpdate) : void
		{
			if (mUpdatables.indexOf(update) != -1)
				return;
			mUpdatables.push(update);
			mPrioritySort = true;
			mNumber++;
		}

		public function unRegister(update : IUpdate) : void
		{
			var index : int = mUpdatables.indexOf(update);
			if (index == -1)
				return;
			mUpdatables.splice(index, 1);
			mNumber--;
		}

		/**
		 * 组件排序
		 *
		 */
		protected function onSort() : void
		{
			mUpdatables.sort(onPrioritySortFun);
			mPrioritySort = false;
		}

		private function onPrioritySortFun(a : IUpdate, b : IUpdate) : int
		{
			if (a.priority > b.priority)
				return 1;
			if (a.priority < b.priority)
				return -1;
			return 0;
		}
	}
}