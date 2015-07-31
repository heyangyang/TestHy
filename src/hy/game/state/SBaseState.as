package hy.game.state
{
	import hy.game.core.GameObject;
	import hy.game.state.interfaces.IBaseState;

	/**
	 * 状态基类
	 * @author hyy
	 *
	 */
	public class SBaseState implements IBaseState
	{
		protected var gameObject : GameObject;
		protected var stateMgr : StateComponent;
		protected var m_id : int;

		public function SBaseState(gameObject : GameObject, stateMgr : StateComponent)
		{
			this.gameObject = gameObject;
			this.stateMgr = stateMgr;
		}

		/**
		 * 尝试是否可以转换该状态
		 * @return
		 *
		 */
		public function tryChangeState() : Boolean
		{
			return true;
		}

		/**
		 * 进入当前动作处理
		 *
		 */
		public function enterState() : void
		{

		}

		/**
		 * 退出当前动作处理
		 *
		 */
		public function exitState() : void
		{

		}

		/**
		 * 更新动作
		 * @param delay
		 *
		 */
		public function update() : void
		{

		}

		/**
		 * 销毁动作
		 *
		 */
		public function destory() : void
		{
			gameObject = null;
			stateMgr = null;
		}

		/**
		 * 动作的id  唯一
		 * @return
		 *
		 */
		public function get id() : int
		{
			return m_id;
		}

	}
}