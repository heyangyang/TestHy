package hy.game.net
{
	import flash.utils.ByteArray;

	import hy.game.core.interfaces.IDispose;

	public class SByteArray extends ByteArray implements IDispose
	{
		protected var mIsDisposed : Boolean;

		public function SByteArray()
		{
			super();
		}

		public function dispose() : void
		{
			mIsDisposed = true;
			this.clear();
		}

		public function get isDispose() : Boolean
		{
			return mIsDisposed;
		}
	}
}