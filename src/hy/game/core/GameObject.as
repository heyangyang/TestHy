package hy.game.core
{
	import flash.utils.Dictionary;

	import hy.game.interfaces.core.IGameObject;
	import hy.game.data.STransform;
	import hy.game.enum.EnumPriority;
	import hy.game.manager.GameObjectManager;
	import hy.game.namespaces.name_part;

	use namespace name_part;

	/**
	 * 游戏对象
	 * 相当于一个容器
	 * @author hyy
	 *
	 */
	public class GameObject extends SUpdate implements IGameObject
	{
		protected var mName : String;
		protected var mTag : String;
		protected var mId : int;
		/**
		 * 更新列表
		 */
		protected var mComponents : Vector.<FrameComponent>;
		/**
		 * 更新组件数量
		 */
		protected var mNumChildren : int;
		/**
		 * 字典，根据类型储存
		 */
		protected var mComponentTypes : Dictionary;
		/**
		 * 容器
		 */
		private var mOwner : GameObjectManager;
		/**
		 * 是否激活
		 */
		protected var mIsActive : Boolean;
		/**
		 * 显示状态的所有属性
		 */
		private var mTransform : STransform;

		public function GameObject()
		{
			super();
			init();
		}

		private function init() : void
		{
			mComponents = new Vector.<FrameComponent>();
			mComponentTypes = new Dictionary(true);
			mNumChildren = 0;
			start();
		}

		/**
		 * 激活时候的处理
		 *
		 */
		public function onActive() : void
		{
		}

		/**
		 * 停止激活时候的处理
		 *
		 */
		public function onDeActive() : void
		{
		}

		/**
		 * 初始化
		 *
		 */
		protected function start() : void
		{

		}

		/**
		 * 必须在注册之前修改才有效
		 * @return
		 *
		 */
		public function set name(value : String) : void
		{
			mName = value;
			if (isRegisterd)
				error("必须在注册之前修改才有效 ");
		}

		public function get name() : String
		{
			return mName;
		}

		/**
		 * 必须在注册之前修改才有效
		 * @return
		 *
		 */
		public function set tag(value : String) : void
		{
			mTag = value;
			if (isRegisterd)
				error("必须在注册之前修改才有效 ");
		}

		public function get tag() : String
		{
			return mTag;
		}

		public function get depth() : int
		{
			return mTransform.y;
		}

		public function get transform() : STransform
		{
			return mTransform;
		}

		public function set transform(value : STransform) : void
		{
			mTransform = value;
			if (!mTransform)
				return;
			mTransform.cleanCall();
			mTransform.addPositionChange(updatePosition);
		}

		public function set activeStatus(value : Boolean) : void
		{
			mIsActive = value;
		}

		public function get activeStatus() : Boolean
		{
			return mIsActive;
		}

		/**
		 * 必须注册后才能使用
		 * @param priority
		 *
		 */
		override public function registerd(priority : int = EnumPriority.PRIORITY_0) : void
		{
			mPriority = priority;
			mRegisterd = true;
			mOwner = GameObjectManager.getInstance();
			if (!mOwner)
				error(this, "mOwner=null");
			mIsActive = true;
			mOwner.push(this);
		}

		override public function unRegisterd() : void
		{
			mRegisterd = false;
			mIsActive = false;
			if (mOwner)
				mOwner.remove(this);
		}

		override public function update() : void
		{
			var component : FrameComponent;
			for (var i : int = mNumChildren - 1; i >= 0; i--)
			{
				component = mComponents[i];
				if (component.isDispose)
					continue;
				!component.mIsStart && component.onInit();
				component.update();
			}
			//检测是否需要通知更新
			transform.excuteNotify();
		}

		/**
		 * 主要用来更新mScreenX，mScreenY属性
		 *
		 */
		protected function updatePosition() : void
		{
			transform.x = transform.x;
			transform.y = transform.y;
		}

		/**
		 * 2分插入法
		 * @param child
		 *
		 */
		private function sort2Push(child : FrameComponent) : void
		{
			if (mNumChildren == 0)
			{
				mComponents.push(child);
				return;
			}
			var tIndex : int = mComponents.indexOf(child);
			//比较的索引
			var tSortIndex : int;
			//区间A，A-B,默认0开始
			var tStartSortIndex : int = 0;
			//区间B，A-B，默认数组长度
			var tEndSortIndex : int = mNumChildren - 1;
			//计算次数
			var tCount : int = 1;
			//每次计算后，区间值
			var tValue : int = tSortIndex = Math.ceil(mNumChildren - 1 >> tCount);
			while (tValue > 0)
			{
				tValue = Math.ceil(mNumChildren - 1 >> ++tCount);
				//如果是自己，则比较前后一个
				if (tSortIndex == tIndex)
				{
					if (child.priority > mComponents[tSortIndex + 1].priority)
						tSortIndex++;
					else
						tSortIndex--;
				}
				//向后查找
				if (child.priority > mComponents[tSortIndex].priority)
				{
					tStartSortIndex = tSortIndex;
					tSortIndex += tValue;
				}
				//向前查找
				else
				{
					tEndSortIndex = tSortIndex;
					tSortIndex -= tValue;
				}
			}
			for (tSortIndex = tStartSortIndex; tSortIndex <= tEndSortIndex; tSortIndex++)
			{
				if (child.priority < mComponents[tSortIndex].priority)
				{
					break;
				}
			}

			//移除以前的
			if (tIndex != -1)
				mComponents.splice(tIndex, 1);
			if (tIndex >= 0 && tIndex < tSortIndex)
				tSortIndex--;
			if (tSortIndex < 0)
				tSortIndex = 0;
			//插入
			mComponents.splice(tSortIndex, 0, child);
		}

		public function addComponent(component : Component, priority : int = 0) : void
		{
			if (!component)
				return;
			var frameComponent : FrameComponent = component as FrameComponent;
			if (frameComponent && mComponents.indexOf(frameComponent) == -1)
			{
				frameComponent.registerd(priority);
				sort2Push(frameComponent);
				mNumChildren++;
			}

			if (component.type == null)
				error(this, "type is null!");
			if (mComponentTypes[component.type])
				error("type :" + component.type + "重复");
			mComponentTypes[component.type] = component;
			component.owner = this;
			component.notifyAdded();
		}

		public function removeComponent(component : Component) : void
		{
			if (mComponentTypes.hasOwnProperty(component.type))
				delete mComponentTypes[component.type];
			component.owner = null;
			var index : int = mComponents.indexOf(component as FrameComponent)
			if (index == -1)
				return;
			mComponents.splice(index, 1);
			mNumChildren--;
		}

		public function removeComponentByType(type : *) : void
		{
			removeComponent(getComponentByType(type));
		}

		public function getComponentByType(type : *) : Component
		{
			return mComponentTypes[type];
		}

		public function get id() : int
		{
			return mId;
		}

		public function set id(value : int) : void
		{
			mId = value;
		}

		private function clearComponents() : void
		{
			var component : Component;
			for (var key : * in mComponentTypes)
			{
				component = mComponentTypes[key];
				component && component.dispose();
				delete mComponentTypes[key];
			}
			mComponents.length = 0;
		}

		override public function dispose() : void
		{
			if (mIsDisposed)
				return;
			unRegisterd();
			mOwner = null;
			clearComponents();
			tag = null;
			name = null;
			super.dispose();
		}
	}
}