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
		private var mPriority : int;
		/**
		 * 是否注册
		 */
		private var mRegisterd : Boolean;

		name_part var mIsStart : Boolean;

		public function FrameComponent(type : * = null)
		{
			super(type);
		}

		name_part function onInit() : void
		{
			mIsStart = true;
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
			return mPriority;
		}

		public function registerd(priority : int = EnumPriority.PRIORITY_0) : void
		{
			mPriority = priority;
			mRegisterd = true;
			mOwner && mOwner.updatePrioritySort();
		}

		public function unRegisterd() : void
		{
			mRegisterd = false;
		}

		public function get isRegisterd() : Boolean
		{
			return mRegisterd;
		}
	}
}