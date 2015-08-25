package hy.game.core
{

	/**
	 * 通知处理
	 * @author hyy
	 *
	 */
	public class SNotify
	{
		private var mNotifyList : Vector.<Function>;

		public function SNotify()
		{
		}

		/**
		 * 添加函数
		 * @param fun
		 *
		 */
		public function addNotify(fun : Function) : void
		{
			if (!fun || notifyList.indexOf(fun) != -1)
				return;
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
		 *
		 */
		public function excuteNotify() : void
		{
			for each (var fun : Function in mNotifyList)
			{
				fun();
			}
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