package hy.game.core
{
	import flash.utils.Dictionary;

	import hy.game.core.interfaces.IContainer;
	import hy.game.core.interfaces.IGameContainer;
	import hy.game.core.interfaces.IGameObject;
	import hy.game.data.STransform;
	import hy.game.enum.PriorityType;
	import hy.game.namespaces.name_part;
	import hy.game.render.SGameRender;

	use namespace name_part;

	/**
	 * 游戏对象
	 * 相当于一个容器
	 * @author hyy
	 *
	 */
	public class GameObject extends SUpdate implements IGameObject
	{
		private static var dic_name : Dictionary = new Dictionary();
		private static var dic_tag : Dictionary = new Dictionary();

		public static function findGameObject(name : String) : GameObject
		{
			if (dic_name[name] == null)
				return null;
			return dic_name[name][0];
		}

		public static function findGameObjects(name : String) : GameObject
		{
			if (dic_name[name] == null)
				return null;
			return dic_name[name];
		}

		public static function findWithTag(name : String) : GameObject
		{
			if (dic_tag[name] == null)
				return null;
			return dic_tag[name][0];
		}

		public static function findWithTags(name : String) : Array
		{
			if (dic_tag[name] == null)
				return null;
			return dic_tag[name];
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
		protected var m_prioritySort : Boolean;
		protected var m_name : String;
		protected var m_tag : String;
		/**
		 * 更新列表
		 */
		protected var m_components : Vector.<FrameComponent>;
		/**
		 * 字典，根据类型储存
		 */
		protected var m_componentTypes : Dictionary;
		/**
		 * 容器
		 */
		private var m_owner : IGameContainer;
		/**
		 * 是否激活
		 */
		protected var m_isActive : Boolean;
		/**
		 * 显示状态的所有属性
		 */
		private var m_transform : STransform;
		/**
		 * 渲染容器
		 */
		protected var m_render : SGameRender;

		public function GameObject()
		{
			super();
			init();
		}

		private function init() : void
		{
			m_components = new Vector.<FrameComponent>();
			m_componentTypes = new Dictionary(true);
			m_transform = new STransform();
			m_render = new SGameRender();
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
			if (m_name == value)
				return;
			if (!m_name)
				removeGameObject(m_name, this, dic_tag);
			m_name = value;
			addGameObject(m_name, this, dic_name);
		}

		public function get name() : String
		{
			return m_name;
		}

		public function set tag(value : String) : void
		{
			if (m_tag == value)
				return;
			if (!m_tag)
				removeGameObject(m_tag, this, dic_tag);
			m_tag = value;
			addGameObject(m_tag, this, dic_tag);
		}

		public function get tag() : String
		{
			return m_tag;
		}

		name_part function set owner(value : IGameContainer) : void
		{
			m_owner = value;
		}

		public function get depth() : int
		{
			return m_transform.y;
		}

		public function get transform() : STransform
		{
			return m_transform;
		}

		public function set activeStatus(value : Boolean) : void
		{
			m_isActive = value;
		}

		public function get activeStatus() : Boolean
		{
			return m_isActive;
		}

		/**
		 * 必须注册后才能使用
		 * @param priority
		 *
		 */
		override public function registerd(priority : int = PriorityType.PRIORITY_0) : void
		{
			super.registerd(priority);
			if (m_owner)
			{
				m_isActive = true;
				m_owner.changePrioritySort();
				m_owner.addObject(this);
				m_owner.addRender(m_render);
			}
		}

		override public function unRegisterd() : void
		{
			if (m_owner)
			{
				m_isActive = false;
				m_owner.removeObject(this);
				m_owner.removeRender(m_render);
			}
		}

		override public function update() : void
		{
			m_prioritySort && onSort();
			var component : FrameComponent;
			for (var i : int = m_components.length - 1; i >= 0; i--)
			{
				component = m_components[i];
				if (component.isDestroy || !component.checkUpdatable())
					continue;
				component.update();
			}
			if (transform.isChange)
			{
				m_render.alpha = transform.alpha;
				m_render.scale = transform.scale;
				m_render.depth = transform.y;
				m_render.x = transform.x;
				m_render.y = transform.y;
				transform.update();
				updateRenderDepthSort();
			}
		}

		/**
		 * 组件排序
		 *
		 */
		protected function onSort() : void
		{
			m_components.sort(onPrioritySortFun);
			m_prioritySort = false;
		}

		private function onPrioritySortFun(a : GameObject, b : GameObject) : int
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
			m_prioritySort = true;
		}

		/**
		 * 通知容器下次需要更新队列
		 *
		 */
		public function updateRenderDepthSort() : void
		{
			m_owner.changeDepthSort();
		}

		public function addComponent(component : Component) : void
		{
			if (!component)
				return;
			var frameComponent : FrameComponent = component as FrameComponent;
			if (frameComponent && m_components.indexOf(frameComponent) == -1)
			{
				updatePrioritySort();
				m_components.push(component);
			}

			if (m_componentTypes[component.type])
				error("type :" + component.type + "重复");
			m_componentTypes[component.type] = component;
			component.owner = this;
			component.notifyAdded();
		}

		public function removeComponent(component : Component) : void
		{
			if (m_componentTypes.hasOwnProperty(component.type))
				delete m_componentTypes[component.type];
			component.owner = null;
			var index : int = m_components.indexOf(component as FrameComponent)
			if (index == -1)
				return;
			m_components.splice(index, 1);
		}

		public function addRender(render : SGameRender) : void
		{
			m_render.addChild(render);
		}

		public function removeRender(render : SGameRender) : void
		{
			m_render.removeChild(render);
		}

		public function removeComponentByType(type : *) : void
		{
			removeComponent(getComponentByType(type));
		}

		public function getComponentByType(type : *) : Component
		{
			return m_componentTypes[type];
		}

		public function addContainer(container : IContainer) : void
		{
			m_owner.addContainer(container, m_owner.numChildren);
		}

		private function clearComponents() : void
		{
			var component : Component;
			for (var i : int = m_components.length - 1; i >= 0; i--)
			{
				component = m_components[i];
				component.destroy();
			}
			m_components.length = 0;
			m_componentTypes = null;
		}

		override public function destroy() : void
		{
			if (m_isDisposed)
				return;
			unRegisterd();
			m_owner = null;
			clearComponents();
			tag = null;
			name = null;
			super.destroy();
		}
	}
}