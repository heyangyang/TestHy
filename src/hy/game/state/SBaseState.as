package hy.game.state
{
	import hy.game.core.GameObject;
	import hy.game.data.SObject;
	import hy.game.data.STransform;
	import hy.game.state.interfaces.IBaseState;
	import hy.rpg.components.data.DataComponent;

	/**
	 * 状态基类
	 * @author hyy
	 *
	 */
	public class SBaseState extends SObject implements IBaseState
	{
		protected var m_action : uint;
		protected var m_transform : STransform;
		protected var m_owner : GameObject;
		protected var m_stageMgr : StateComponent;
		protected var m_data : DataComponent;
		protected var m_id : int;

		public function SBaseState(gameObject : GameObject, stateMgr : StateComponent)
		{
			this.m_owner = gameObject;
			this.m_stageMgr = stateMgr;
			m_transform = gameObject.transform;
			m_data = gameObject.getComponentByType(DataComponent) as DataComponent;
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
			if (m_action != m_data.action)
			{
				m_data.action = m_action;
			}
		}

		public function changeStateId(id : int) : void
		{
			m_stageMgr.changeStateById(id);
		}


		/**
		 * 销毁动作
		 *
		 */
		public function destory() : void
		{
			m_owner = null;
			m_stageMgr = null;
		}

		/**
		 * 动作的id  唯一
		 * @return
		 *
		 */
		public function get id() : int
		{
			if (m_id == 0)
				warning(this, "stateId is null");
			return m_id;
		}

	}
}