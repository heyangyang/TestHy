package hy.game.core
{

	import hy.game.interfaces.component.IComponent;
	import hy.game.interfaces.core.IRecycle;
	import hy.game.manager.SMemeryManager;
	import hy.game.namespaces.name_part;
	import hy.game.utils.SDebug;

	public class Component implements IComponent, IRecycle
	{
		/**
		 * 类型
		 */
		protected var mType : *;
		/**
		 * 容器
		 */
		protected var mOwner : GameObject;

		/**
		 * 是否被销毁
		 */
		protected var mIsDisposed : Boolean;

		public function Component(type : * = null)
		{
			if (type == null)
				type = this["constructor"];
			mType = type;
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
			mOwner = value;
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
			return mType;
		}
		
		public function get gameObject():GameObject
		{
			return mOwner;
		}

		/**
		 * 是否销毁
		 */
		public function get isDispose() : Boolean
		{
			return mIsDisposed;
		}

		/**
		 * 回收
		 *
		 */
		public function recycle() : void
		{
			SMemeryManager.recycleObject(this);
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

		public function dispose() : void
		{
			if (mIsDisposed)
				return;
			notifyRemoved();
			if (mOwner)
			{
				mOwner.removeComponent(this);
				mOwner = null;
			}
			mType = null;
			mIsDisposed = true;
		}
	}
}