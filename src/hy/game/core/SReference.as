package hy.game.core
{
	import hy.game.utils.SDebug;

	/**
	 * 实例引用
	 *
	 */
	public class SReference
	{
		private var m_allowDestroy : Boolean;
		private var m_isDisposed : Boolean;
		private var m_referenceCount : uint;
		public var lastUseTime : uint;

		public function SReference()
		{
			super();
			m_isDisposed = false;
			m_allowDestroy = false;
			m_referenceCount = 0;
			retain();
		}

		public function retain() : void
		{
			if (m_isDisposed)
				return;
			++m_referenceCount;
			m_allowDestroy = false;
		}

		public function release() : void
		{
			if (m_isDisposed)
				return;
			lastUseTime = STime.getTimer;
			--m_referenceCount;
			if (m_referenceCount < 0)
				error(this, "release error");
			if (m_referenceCount == 0)
			{
				m_allowDestroy = true;
			}
		}

		public function get isDisposed() : Boolean
		{
			return m_isDisposed;
		}

		public function tryDestroy() : Boolean
		{
			if (m_isDisposed)
				return false;
			if (m_allowDestroy)
			{
				destroy();
				return true;
			}
			return false;
		}

		public function forceDestroy() : void
		{
			if (m_isDisposed)
				return;
			destroy();
		}

		public function get allowDestroy() : Boolean
		{
			return m_allowDestroy;
		}

		public function get isDestroy() : Boolean
		{
			return m_isDisposed;
		}

		/**
		 * 清除内存
		 */
		protected function destroy() : void
		{
			m_isDisposed = true;
			m_allowDestroy = false;
			m_referenceCount = 0;
		}

		protected function print(... args) : void
		{
			SDebug.print.apply(this, args);
		}

		protected function warning(... args) : void
		{
			SDebug.warning.apply(this, args);
		}

		protected function error(... args) : void
		{
			SDebug.error.apply(this, args);
		}
	}
}