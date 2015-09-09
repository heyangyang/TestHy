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
		protected var mAction : uint;
		protected var mTransform : STransform;
		protected var mOwner : GameObject;
		protected var mStageMgr : StateComponent;
		protected var mData : DataComponent;
		protected var mId : int;

		public function SBaseState(gameObject : GameObject, stateMgr : StateComponent)
		{
			this.mOwner = gameObject;
			this.mStageMgr = stateMgr;
			mTransform = gameObject.transform;
			mData = gameObject.getComponentByType(DataComponent) as DataComponent;
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
			if (mAction != mTransform.action)
			{
				mTransform.action = mAction;
			}
		}

		public function changeStateId(id : int) : void
		{
			mStageMgr.changeStateById(id);
		}


		/**
		 * 销毁动作
		 *
		 */
		public function destory() : void
		{
			mOwner = null;
			mStageMgr = null;
		}

		/**
		 * 动作的id  唯一
		 * @return
		 *
		 */
		public function get id() : int
		{
			if (mId == 0)
				warning(this, "stateId is null");
			return mId;
		}

	}
}