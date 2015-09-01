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
		private var mParams : Object;

		public function SCall(params : Object = null)
		{
			mParams = params;
		}

		/**
		 * 参数
		 * @param value
		 *
		 */
		public function set data(value : Object) : void
		{
			mParams = value;
		}

		/**
		 * 添加函数
		 * @param fun
		 *
		 */
		public function push(fun : Function, index : int = -1) : void
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
		public function remove(fun : Function) : void
		{
			if (!fun)
				return;
			var index : int = notifyList.indexOf(fun);
			if (index != -1)
				mNotifyList.splice(index, 1);
		}

		/**
		 * 检测是否处理通知
		 * @param update 是否强制更新
		 * @param isClean是否清理通知
		 *
		 */
		public function checkExcute(update : Boolean = false, isClean : Boolean = false) : void
		{
			if (!mIsUpdatable && !update)
				return;
			mIsUpdatable = false;
			excute(isClean);
		}

		/**
		 * 处理通知,无需检测
		 * @param isClean是否清理通知
		 */
		public function excute(isClean : Boolean = false) : void
		{
			for each (var fun : Function in mNotifyList)
			{
				if (mParams)
					fun.length > 1 ? fun.apply(this, mParams) : fun(mParams);
				else
					fun();
			}
			isClean && clean();
		}

		/**
		 * 标记更新状态
		 *
		 */
		public function updateCallStatus() : void
		{
			mIsUpdatable = true;
		}

		/**
		 * 清理通知列表
		 *
		 */
		public function clean() : void
		{
			if (mNotifyList)
				mNotifyList.length = 0;
		}

		public function dispose() : void
		{
			clean();
			mParams = null;
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