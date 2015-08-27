package hy.game.core
{
	import flash.utils.Dictionary;

	import hy.game.core.interfaces.IGameContainer;
	import hy.game.core.interfaces.IGameObject;
	import hy.game.data.STransform;
	import hy.game.enum.EnumPriority;
	import hy.game.namespaces.name_part;
	import hy.game.render.SRender;

	use namespace name_part;

	/**
	 * 游戏对象
	 * 相当于一个容器
	 * @author hyy
	 *
	 */
	public class GameObject extends SUpdate implements IGameObject
	{
		private static var sDic_name : Dictionary = new Dictionary();
		private static var sDic_tag : Dictionary = new Dictionary();

		public static function findGameObject(name : String) : GameObject
		{
			if (sDic_name[name] == null)
				return null;
			return sDic_name[name][0];
		}

		public static function findGameObjects(name : String) : GameObject
		{
			if (sDic_name[name] == null)
				return null;
			return sDic_name[name];
		}

		public static function findWithTag(name : String) : GameObject
		{
			if (sDic_tag[name] == null)
				return null;
			return sDic_tag[name][0];
		}

		public static function findWithTags(name : String) : Array
		{
			if (sDic_tag[name] == null)
				return null;
			return sDic_tag[name];
		}

		private static function addGameObject(name : String, gameObject : GameObject, dic : Dictionary) : void
		{
			if (!name)
				return;
			var list : Array;
			if (dic[name] == null)
				dic[name] = [];
			list = dic[name];
			if (list.indexOf(gameObject) == -1)
				list.push(gameObject);
		}

		private static function removeGameObject(name : String, gameObject : GameObject, dic : Dictionary) : void
		{
			if (!name)
				return;
			var list : Array;
			if (dic[name] == null)
				dic[name] = [];
			list = dic[name];
			var index : int = list.indexOf(gameObject);
			if (index != -1)
				list.splice(index, 1);
		}

		/**
		 * 是否需要排序组件
		 */
		protected var mPrioritySort : Boolean;
		protected var mName : String;
		protected var mTag : String;
		protected var mId : int;
		/**
		 * 更新列表
		 */
		protected var mComponents : Vector.<FrameComponent>;
		/**
		 * 字典，根据类型储存
		 */
		protected var mComponentTypes : Dictionary;
		/**
		 * 容器
		 */
		private var mOwner : IGameContainer;
		/**
		 * 是否激活
		 */
		protected var mIsActive : Boolean;
		/**
		 * 显示状态的所有属性
		 */
		private var mTransform : STransform;
		/**
		 * 渲染容器
		 */
		protected var mRender : SRender;

		public function GameObject()
		{
			super();
			init();
		}

		private function init() : void
		{
			mComponents = new Vector.<FrameComponent>();
			mComponentTypes = new Dictionary(true);
			mRender = new SRender();
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

		public function set name(value : String) : void
		{
			if (mName == value)
				return;
			if (!mName)
				removeGameObject(mName, this, sDic_tag);
			mName = value;
			addGameObject(mName, this, sDic_name);
		}

		public function get name() : String
		{
			return mName;
		}

		public function set tag(value : String) : void
		{
			if (mTag == value)
				return;
			if (!mTag)
				removeGameObject(mTag, this, sDic_tag);
			mTag = value;
			addGameObject(mTag, this, sDic_tag);
		}

		public function get tag() : String
		{
			return mTag;
		}

		name_part function set owner(value : IGameContainer) : void
		{
			mOwner = value;
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
			mTransform.clearCall();
			mTransform.addPositionChange(positionChange);
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
			if (!mOwner)
				error(this, "mOwner=null");
			mIsActive = true;
			mOwner.changePrioritySort();
			mOwner.addObject(this);
			mOwner.addRender(mRender);
		}

		override public function unRegisterd() : void
		{
			if (mOwner)
			{
				mIsActive = false;
				mOwner.removeRender(mRender);
				mOwner.removeObject(this);
			}
		}

		override public function update() : void
		{
			mPrioritySort && onSort();
			var component : FrameComponent;
			for (var i : int = mComponents.length - 1; i >= 0; i--)
			{
				component = mComponents[i];
				if (component.isDestroy)
					continue;
				!component.mIsStart && component.onInit();
				component.update();
			}
			mRender.needLayerSort && mRender.onLayerSort();
			updateTransform();
		}

		protected function positionChange() : void
		{
			transform.x = transform.x;
			transform.y = transform.y;
			mRender.x = transform.screenX;
			mRender.y = transform.screenY;
			mRender.depth = transform.y;
		}

		/**
		 * 更新transform的一些信息
		 *
		 */
		protected function updateTransform() : void
		{
			if (SCameraObject.isMoving)
			{
				positionChange();
			}
			//更新后，设置成为改变
			transform.excuteNotify();
		}


		/**
		 * 组件排序
		 *
		 */
		protected function onSort() : void
		{
			mComponents.sort(onPrioritySortFun);
			mPrioritySort = false;
		}

		private function onPrioritySortFun(a : FrameComponent, b : FrameComponent) : int
		{
			if (a.priority > b.priority)
				return 1;
			if (a.priority < b.priority)
				return -1;
			return 0;
		}

		/**
		 * 设置排序状态
		 *
		 */
		public function updatePrioritySort() : void
		{
			mPrioritySort = true;
		}

		public function addComponent(component : Component, priority : int = 0) : void
		{
			if (!component)
				return;
			var frameComponent : FrameComponent = component as FrameComponent;
			if (frameComponent && mComponents.indexOf(frameComponent) == -1)
			{
				updatePrioritySort();
				mComponents.push(component);
				frameComponent.registerd(priority);
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
		}

		public function addRender(render : SRender) : void
		{
			mRender.addChild(render);
		}

		public function removeRender(render : SRender) : void
		{
			mRender && mRender.removeChild(render);
		}

		public function removeComponentByType(type : *) : void
		{
			removeComponent(getComponentByType(type));
		}

		public function getComponentByType(type : *) : Component
		{
			return mComponentTypes[type];
		}

		public function get render() : SRender
		{
			return mRender;
		}

		private function clearComponents() : void
		{
			var component : Component;
			for (var key : * in mComponentTypes)
			{
				component = mComponentTypes[key];
				component && component.destroy();
				delete mComponentTypes[key];
			}
			mComponents.length = 0;
		}

		override public function destroy() : void
		{
			if (mIsDisposed)
				return;
			unRegisterd();
			mRender && mRender.dispose();
			mRender = null;
			mOwner = null;
			clearComponents();
			tag = null;
			name = null;
			super.destroy();
		}

		public function get id() : int
		{
			return mId;
		}

		public function set id(value : int) : void
		{
			mId = value;
		}

	}
}