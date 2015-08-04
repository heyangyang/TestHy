package hy.game.core
{
	import hy.game.core.event.SEventDispatcher;

	public class GameDispatcher extends SEventDispatcher
	{
		public static const RESIZE : String = "RESIZE";

		private static var instance : GameDispatcher;

		public static function getInstance() : GameDispatcher
		{
			if (!instance)
				instance = new GameDispatcher();
			return instance;
		}

		public function GameDispatcher()
		{
			super();
		}

		public static function addEventListener(type : String, listener : Function) : void
		{
			instance.addEventListener(type, listener);
		}

		public static function removeEventListener(type : String, listener : Function) : void
		{
			instance.removeEventListener(type, listener);
		}

		public static function removeEventListeners(type : String = null) : void
		{
			instance.removeEventListeners();
		}

		public static function dispatch(type : String, data : Object = null) : void
		{
			instance.dispatchEventWith(type, data);
		}
	}
}