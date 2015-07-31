package hy.game.core
{
	import hy.game.core.interfaces.IUpdate;

	import hy.game.cfg.Config;

	import hy.game.enum.EnumPriority;

	public class FrameComponent extends Component implements IUpdate
	{
		/**
		 * 更新帧数
		 */
		private var m_frameRate : uint = 0;
		/**
		 * 更新优先级
		 */
		protected var m_priority : int;
		/**
		 * 是否注册
		 */
		protected var m_registerd : Boolean;
		/**
		 * 更新间隔
		 */
		private var m_frameInterval : uint = 0;
		/**
		 * 记录当前持续时间
		 */
		protected var m_frameElapsedTime : uint = 0;
		/**
		 * 是否需要检测更新
		 */
		protected var m_checkUpdateable : Boolean = false;
		/**
		 * 注册等级
		 */
		protected var m_registerdLevel : int;

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

		public function checkUpdatable() : Boolean
		{
			if (!m_checkUpdateable)
			{
				return true;
			}
			m_frameElapsedTime += STime.deltaTime;

			if (m_frameElapsedTime >= m_frameInterval)
			{
				m_frameElapsedTime -= m_frameInterval;
				return true;
			}
			return false;
		}

		public function get frameRate() : uint
		{
			return m_frameRate;
		}

		public function set frameRate(value : uint) : void
		{
			if (value <= 0)
			{
				m_checkUpdateable = false;
				return;
			}
			if (value >= Config.frameRate)
				value = Config.frameRate;
			m_frameRate = value;
			m_frameInterval = Math.floor(1000 / m_frameRate);
			m_checkUpdateable = true;
		}

		public function get priority() : int
		{
			return m_priority;
		}

		public function set priority(value : int) : void
		{
			m_priority = value;
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

		/**
		 * 更新间隔
		 */
		public function get frameInterval() : uint
		{
			return m_frameInterval;
		}

		/**
		 * @private
		 */
		public function set frameInterval(value : uint) : void
		{
			m_frameInterval = value;
			m_checkUpdateable = true;
		}
	}
}