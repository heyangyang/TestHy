package hy.game.core
{
	import hy.game.utils.SDebug;

	/**
	 * 实例引用
	 *
	 */
	public class SReference
	{
		private var mAllowDestroy : Boolean;
		private var mIsDisposed : Boolean;
		private var mReferenceCount : uint;
		public var lastUseTime : uint;

		public function SReference()
		{
			super();
			mIsDisposed = false;
			mAllowDestroy = false;
			mReferenceCount = 0;
			retain();
		}

		public function retain() : void
		{
			if (mIsDisposed)
				return;
			++mReferenceCount;
			mAllowDestroy = false;
		}

		public function release() : void
		{
			if (mIsDisposed)
				return;
			lastUseTime = STime.getTimer;
			--mReferenceCount;
			if (mReferenceCount < 0)
				error(this, "release error");
			if (mReferenceCount == 0)
			{
				mAllowDestroy = true;
			}
		}

		public function get isDisposed() : Boolean
		{
			return mIsDisposed;
		}

		public function tryDestroy() : Boolean
		{
			if (mIsDisposed)
				return false;
			if (mAllowDestroy)
			{
				dispose();
				return true;
			}
			return false;
		}

		public function forceDestroy() : void
		{
			if (mIsDisposed)
				return;
			dispose();
		}

		public function get allowDestroy() : Boolean
		{
			return mAllowDestroy;
		}

		public function get isDestroy() : Boolean
		{
			return mIsDisposed;
		}

		/**
		 * 清除内存
		 */
		protected function dispose() : void
		{
			mIsDisposed = true;
			mAllowDestroy = false;
			mReferenceCount = 0;
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