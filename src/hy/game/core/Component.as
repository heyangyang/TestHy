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
			onStart();
		}

		protected function onStart() : void
		{

		}

		name_part function set owner(value : GameObject) : void
		{
			m_owner = value;
		}

		public function notifyAdded() : void
		{
		}

		public function notifyRemoved() : void
		{
		}

		public function get type() : *
		{
			return m_type;
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