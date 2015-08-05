package hy.game.core
{

	import hy.game.core.interfaces.IComponent;
	import hy.game.core.interfaces.IDestroy;
	import hy.game.core.interfaces.IRecycle;
	import hy.game.manager.SObjectManager;
	import hy.game.namespaces.name_part;
	import hy.game.utils.SDebug;

	public class Component implements IComponent, IDestroy, IRecycle
	{
		/**
		 * 类型
		 */
		protected var m_type : *;
		/**
		 * 容器
		 */
		protected var m_owner : GameObject;

		/**
		 * 是否被销毁
		 */
		protected var m_isDisposed : Boolean;

		public function Component(type : * = null)
		{
			if (type == null)
				type = this["constructor"];
			m_type = type;
			init();
		}

		/**
		 * 初始化，只运行一次
		 *
		 */
		protected function init() : void
		{

		}

		name_part function set owner(value : GameObject) : void
		{
			m_owner = value;
		}

		/**
		 * 添加到容器的时候调用
		 * 一般参数设置，写这里
		 *
		 */
		public function notifyAdded() : void
		{
		}

		/**
		 * 移除出容器的时候调用
		 * 销毁的时候也会调用
		 *
		 */
		public function notifyRemoved() : void
		{
		}

		public function get type() : *
		{
			return m_type;
		}
		
		public function get gameObject():GameObject
		{
			return m_owner;
		}

		/**
		 * 是否销毁
		 */
		public function get isDestroy() : Boolean
		{
			return m_isDisposed;
		}

		/**
		 * 回收
		 *
		 */
		public function recycle() : void
		{
			SObjectManager.recycleObject(this);
		}

		public function print(... args) : void
		{
			SDebug.print(args.join(","));
		}

		public function waring(... args) : void
		{
			SDebug.warning(args.join(","));
		}

		public function error(... args) : void
		{
			SDebug.error(args.join(","));
		}

		public function destroy() : void
		{
			if (m_isDisposed)
				return;
			notifyRemoved();
			if (m_owner)
			{
				m_owner.removeComponent(this);
				m_owner = null;
			}
			m_type = null;
			m_isDisposed = true;
		}
	}
}