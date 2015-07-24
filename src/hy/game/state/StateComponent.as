package hy.game.state
{
	import flash.utils.Dictionary;
	
	import hy.game.core.FrameComponent;
	import hy.game.state.interfaces.IBaseState;

	/**
	 * 状态机
	 * @author hyy
	 *
	 */
	public class StateComponent extends FrameComponent
	{
		private var stateDictionary : Dictionary = new Dictionary();
		private var currState : IBaseState;
		public var oldStateId : int;

		public function StateComponent(type : * = null)
		{
			super(type);
		}

		override public function notifyAdded() : void
		{
		}

		override public function update() : void
		{
			currState && currState.update();
		}

		/**
		 * 根据id切换动作
		 * @param id
		 * @return
		 *
		 */
		public function changeStateById(id : int) : Boolean
		{
			if (!stateDictionary[id])
			{
				error("not find state:", id);
				return false;
			}

			//不能转换成功
			if (!IBaseState(stateDictionary[id]).tryChangeState())
			{
				return false;
			}

			//清理上一个状态
			if (currState)
			{
				currState.exitState();
				oldStateId = currState.id;
			}
			currState = stateDictionary[id];
			currState.enterState();
			return true;
		}

		public function getStateById(id : int) : IBaseState
		{
			return stateDictionary[id];
		}

		/**
		 * 根据一串类名数组，初始化状态机
		 * @param statesClass
		 *
		 */
		public function setStates(statesClass : Array) : void
		{
			var state : IBaseState;
			for each (var stateClass : Class in statesClass)
			{
				state = new stateClass(m_owner, this);
				if (stateDictionary[state.id])
					error("state is same : ", state.id);
				stateDictionary[state.id] = state;
			}
		}

		/**
		 * 获得当前状态id
		 * @return
		 *
		 */
		public function get currStateId() : int
		{
			if (!currState)
				return -1;
			return currState.id;
		}

		/**
		 * 销毁
		 *
		 */
		override public function destroy() : void
		{
			super.destroy();
			var state : IBaseState;

			for each (state in stateDictionary)
			{
				state.destory();
			}
			stateDictionary = null;
			currState = null;
		}

	}
}