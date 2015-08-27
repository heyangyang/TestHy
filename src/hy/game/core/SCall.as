package hy.game.core
{

	/**
	 * 通知处理
	 * @author hyy
	 *
	 */
	public class SCall
	{
		private var mNotifyList : Vector.<Function>;
		private var mIsUpdatable : Boolean;

		public function SCall()
		{
		}

		/**
		 * 添加函数
		 * @param fun
		 *
		 */
		public function addNotify(fun : Function, index : int = -1) : void
		{
			if (!fun || notifyList.indexOf(fun) != -1)
				return;
			if (index != -1)
			{
				mNotifyList.splice(0, 0, fun);
				return;
			}
			mNotifyList.push(fun);
		}

		/**
		 * 移除函数
		 * @param fun
		 *
		 */
		public function removeNotify(fun : Function) : void
		{
			if (!fun)
				return;
			var index : int = notifyList.indexOf(fun);
			if (index != -1)
				mNotifyList.splice(index, 1);
		}

		/**
		 * 实行处理通知
		 * @param update 是否强制更新
		 *
		 */
		public function excuteNotify(update : Boolean = false) : void
		{
			if (!mIsUpdatable && !update)
				return;
			mIsUpdatable = false;
			for each (var fun : Function in mNotifyList)
			{
				fun();
			}
		}

		public function callUpdate() : void
		{
			mIsUpdatable = true;
		}

		/**
		 * 清理通知列表
		 *
		 */
		public function clearNotify() : void
		{
			if (mNotifyList)
				mNotifyList.length = 0;
		}

		public function dispose() : void
		{
			clearNotify();
			mNotifyList = null;
		}

		private function get notifyList() : Vector.<Function>
		{
			if (mNotifyList == null)
				mNotifyList = new Vector.<Function>();
			return mNotifyList;
		}
	}
}