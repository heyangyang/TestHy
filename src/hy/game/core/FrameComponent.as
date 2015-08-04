package hy.game.core
{
	import hy.game.enum.EnumPriority;
	import hy.game.namespaces.name_part;
	use namespace name_part;

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

		name_part var isStart : Boolean;

		public function FrameComponent(type : * = null)
		{
			super(type);
		}

		name_part function onInit() : void
		{
			isStart = true;
			onStart();
		}

		/**
		 * 第一次更新前创调用
		 * 一般引用，写这里
		 */
		protected function onStart() : void
		{

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