package hy.game.core
{
	import hy.game.enum.EnumPriority;

	public class FrameComponent extends Component
	{
		/**
		 * 更新优先级
		 */
		private var m_priority : int;
		/**
		 * 是否注册
		 */
		private var m_registerd : Boolean;

		public function FrameComponent(type : * = null)
		{
			super(type);
		}

		/**
		 * @param delay
		 *
		 */
		public function update() : void
		{
		}


		public function get priority() : int
		{
			return m_priority;
		}

		public function registerd(priority : int = EnumPriority.PRIORITY_0) : void
		{
			m_priority = priority;
			m_registerd = true;
			m_owner && m_owner.updatePrioritySort();
		}

		public function unRegisterd() : void
		{
			m_registerd = false;
		}

		public function get isRegisterd() : Boolean
		{
			return m_registerd;
		}
	}
}