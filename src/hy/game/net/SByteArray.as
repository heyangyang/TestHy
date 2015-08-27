package hy.game.net
{
	import flash.utils.ByteArray;

	import hy.game.core.interfaces.IDestroy;

	public class SByteArray extends ByteArray implements IDestroy
	{
		protected var mIsDisposed : Boolean;

		public function SByteArray()
		{
			super();
		}

		public function destroy() : void
		{
			mIsDisposed = true;
			this.clear();
		}

		public function get isDestroy() : Boolean
		{
			return mIsDisposed;
		}
	}
}