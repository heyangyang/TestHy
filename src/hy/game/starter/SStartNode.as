package hy.game.starter
{

	/**
	 * 启动器节点
	 * @author wait
	 *
	 */
	public class SStartNode implements IStartNode
	{
		private var mExcuteHandler : Function;

		public function SStartNode()
		{

		}

		/**
		 * 启动器初始化
		 *
		 */
		public function onStart() : void
		{
		}

		public function update() : void
		{
		}

		/**
		 * 启动器退出
		 *
		 */
		public function onExit() : void
		{
		}

		public function setHandler(excuteHandler : Function) : void
		{
			this.mExcuteHandler = excuteHandler;
		}

		/**
		 * 下一个节点
		 *
		 */
		protected function nextNode() : void
		{
			mExcuteHandler != null && mExcuteHandler();
			mExcuteHandler = null;
		}

		/**
		 * 必须覆盖
		 * @return
		 *
		 */
		public function get id() : String
		{
			return null;
		}
	}
}