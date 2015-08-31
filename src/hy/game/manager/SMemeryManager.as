package hy.game.manager
{
	import flash.utils.Dictionary;
	
	import hy.game.cfg.Config;
	import hy.game.core.interfaces.IRecycle;

	/**
	 * 对象回收管理
	 * @author yangyang
	 *
	 */
	public class SMemeryManager
	{

		private static var sMemory : Dictionary = new Dictionary();

		public function SMemeryManager()
		{
		}

		/**
		 * 垃圾回收
		 *
		 */
		public static function recycleObject(obj : *) : void
		{
			if (obj == null)
				return;
			if (obj is IRecycle)
				obj.recycle();
			recycleObjects(obj);
		}

		private static function recycleObjects(obj : *) : void
		{
			var resClass : Class = obj["constructor"];
			var tmpArr : Array = sMemory[resClass];

			if (tmpArr == null || tmpArr.length == 0)
			{
				sMemory[resClass] = [obj];
				return;
			}
			if (tmpArr.length <= Config.RECYCLE_MEMORY_MAX && tmpArr.indexOf(obj) == -1)
			{
				tmpArr.push(obj);
			}
		}

		/**
		 * 获得垃圾站的对象
		 * @param resClass
		 * @return
		 *
		 */
		public static function getObject(resClass : Class, param : * = null) : *
		{
			var tmpArr : Array = sMemory[resClass];
			if (tmpArr == null || tmpArr.length == 0)
			{
				if (param)
					return new resClass(param);
				return new resClass();
			}
			return tmpArr.pop();
		}
	}
}