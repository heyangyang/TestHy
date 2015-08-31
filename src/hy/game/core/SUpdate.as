package hy.game.core
{
	import hy.game.cfg.Config;
	import hy.game.core.interfaces.IUpdate;
	import hy.game.enum.EnumPriority;
	import hy.game.manager.SUpdateManager;
	import hy.game.utils.SDebug;

	public class SUpdate implements IUpdate
	{
		/**
		 * 更新帧数
		 */
		private var mFrameRate : uint = 0;
		/**
		 * 更新优先级
		 */
		protected var mPriority : int;
		/**
		 * 是否注册
		 */
		protected var mRegisterd : Boolean;
		/**
		 * 更新间隔
		 */
		private var mFrameInterval : uint = 0;
		/**
		 * 记录当前持续时间
		 */
		protected var mFrameElapsedTime : uint = 0;
		/**
		 * 是否需要检测更新
		 */
		protected var mCheckUpdateable : Boolean = false;
		/**
		 * 是否销毁
		 */
		protected var mIsDisposed : Boolean = false;

		/**
		 * 注册等级
		 */
		protected var mRegisterdLevel : int;

		public function SUpdate()
		{
			init();
		}

		/**
		 * 初始化
		 *
		 */
		protected function init() : void
		{

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
			if (!mCheckUpdateable)
			{
				return true;
			}
			mFrameElapsedTime += STime.deltaTime;

			if (mFrameElapsedTime >= mFrameInterval)
			{
				mFrameElapsedTime -= mFrameInterval;
				return true;
			}
			return false;
		}

		public function get frameRate() : uint
		{
			return mFrameRate;
		}

		public function set frameRate(value : uint) : void
		{
			if (value <= 0)
			{
				mCheckUpdateable = false;
				return;
			}
			if (value >= Config.frameRate)
				value = Config.frameRate;
			mFrameRate = value;
			mFrameInterval = Math.floor(1000 / mFrameRate);
			mCheckUpdateable = true;
		}

		/**
		 * 数值越大，优先级别越高
		 * @return
		 *
		 */
		public function get priority() : int
		{
			return mPriority;
		}

		public function set priority(value : int) : void
		{
			mPriority = value;
		}

		/**
		 * @param priority优先级别,越高越优先
		 *
		 */
		public function registerd(priority : int = EnumPriority.PRIORITY_0) : void
		{
			SUpdateManager.getInstance().register(this);
			mPriority = priority;
			mRegisterd = true;
		}

		public function unRegisterd() : void
		{
			SUpdateManager.getInstance().unRegister(this);
			mRegisterd = false;
		}

		public function get isRegisterd() : Boolean
		{
			return mRegisterd;
		}

		/**
		 * 更新间隔
		 */
		public function get frameInterval() : uint
		{
			return mFrameInterval;
		}

		/**
		 * @private
		 */
		public function set frameInterval(value : uint) : void
		{
			mFrameInterval = value;
			mCheckUpdateable = true;
		}

		public function dispose() : void
		{
			mIsDisposed = true;
			mRegisterd = false;
		}

		/**
		 * 是否销毁
		 */
		public function get isDispose() : Boolean
		{
			return mIsDisposed;
		}


		public function print(... args) : void
		{
			SDebug.print(args.join(","));
		}

		public function warning(... args) : void
		{
			SDebug.warning(args.join(","));
		}

		public function error(... args) : void
		{
			SDebug.error(args.join(","));
		}
	}
}