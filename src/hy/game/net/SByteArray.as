package hy.game.net
{
	import flash.utils.ByteArray;

	import hy.game.core.interfaces.IDestroy;

	public class SByteArray extends ByteArray implements IDestroy
	{
		protected var m_isDisposed : Boolean;

		public function SByteArray()
		{
			super();
		}

		public function destroy() : void
		{
			m_isDisposed = true;
			this.clear();
		}

		public function get isDestroy() : Boolean
		{
			return m_isDisposed;
		}
	}
}