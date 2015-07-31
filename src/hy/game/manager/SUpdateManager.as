package hy.game.manager
{
	import flash.display.Stage;
	import flash.events.Event;
	
	import hy.game.core.FrameComponent;
	import hy.game.core.interfaces.IUpdate;

	public class SUpdateManager extends SBaseManager
	{
		private static var instance : SUpdateManager;

		public static function getInstance() : SUpdateManager
		{
			if (instance == null)
				instance = new SUpdateManager();
			return instance;
		}

		private var m_updatables : Vector.<IUpdate> = new Vector.<IUpdate>();
		private var m_prioritySort : Boolean;
		private var m_number : int;
		private var m_update : IUpdate;

		public function SUpdateManager()
		{
			super();
		}

		public function init(stage : Stage) : void
		{
			stage.addEventListener(Event.ENTER_FRAME, onEnterFrame, false, 998);
		}

		private function onEnterFrame(evt : Event) : void
		{
			m_prioritySort && onSort();
			for (var i : int = m_number - 1; i >= 0; i--)
			{
				m_update = m_updatables[i];
				if (m_update.isDestroy || !m_update.checkUpdatable())
					continue;
				m_update.update();
			}
		}

		public function register(update : IUpdate) : void
		{
			if (m_updatables.indexOf(update) != -1)
				return;
			m_updatables.push(update);
			m_prioritySort = true;
			m_number++;
		}

		public function unRegister(update : IUpdate) : void
		{
			var index : int = m_updatables.indexOf(update);
			if (index == -1)
				return;
			m_updatables.splice(index, 1);
			m_number--;
		}

		/**
		 * 组件排序
		 *
		 */
		protected function onSort() : void
		{
			m_updatables.sort(onPrioritySortFun);
			m_prioritySort = false;
		}

		private function onPrioritySortFun(a : FrameComponent, b : FrameComponent) : int
		{
			if (a.priority > b.priority)
				return 1;
			if (a.priority < b.priority)
				return -1;
			return 0;
		}
	}
}