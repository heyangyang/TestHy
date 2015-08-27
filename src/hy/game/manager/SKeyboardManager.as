package hy.game.manager
{
	import flash.display.Stage;
	import flash.events.KeyboardEvent;
	import flash.utils.Dictionary;

	import hy.game.utils.SKeycode;

	/**
	 * 键盘处理管理
	 * @author hyy
	 *
	 */
	public class SKeyboardManager extends SBaseManager
	{
		private static var instance : SKeyboardManager;

		public static function getInstance() : SKeyboardManager
		{
			if (!instance)
				instance = new SKeyboardManager();
			return instance;
		}

		private const KEY_CTRL : int = Math.pow(2, 0);
		private const KEY_ALT : int = Math.pow(2, 1);
		private const KEY_SHIFT : int = Math.pow(2, 2);
		private var mGolbal_dic : Dictionary;
		private var mKey : int;
		private var mCurDic : Dictionary;
		private var mExcuteFunction : Function;

		public function SKeyboardManager()
		{
			if (instance)
				error("instance != null");
			mGolbal_dic = new Dictionary();
		}

		public function init(stage : Stage) : void
		{
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDownHandler);
		}

		private function onKeyDownHandler(evt : KeyboardEvent) : void
		{
			mKey = 0;
			if (evt.ctrlKey)
				mKey += KEY_CTRL;
			if (evt.altKey)
				mKey += KEY_ALT;
			if (evt.shiftKey)
				mKey += KEY_SHIFT;
			mCurDic = mGolbal_dic[mKey];
			if (mCurDic == null)
				return;
			mExcuteFunction = mCurDic[evt.keyCode];
			mExcuteFunction != null && mExcuteFunction();
			mExcuteFunction = null;
		}

		public function addKeyDownHandler(fun : Function, keyCode : int, ... args) : void
		{
			if (fun == null)
			{
				error(this, "function is null!");
				return;
			}
			mKey = getKeyCode(args);
			if (keyCode == 0)
				return;
			mCurDic = mGolbal_dic[mKey];
			if (mCurDic == null)
				mGolbal_dic[mKey] = mCurDic = new Dictionary();
			if (mCurDic[keyCode])
				warning("key is exist : " + keyCode);
			mCurDic[keyCode] = fun;
		}

		public function removeKeyDownHandler(keyCode : uint, ... args) : void
		{
			if (keyCode == 0)
				return;
			mKey = getKeyCode(args);
			mCurDic = mGolbal_dic[mKey];
			if (!mCurDic)
				return;
			mCurDic[keyCode] = null;
			delete mCurDic[keyCode];
		}

		private function getKeyCode(args : Array) : int
		{
			var key : int = 0;
			for (var i : int = args.length - 1; i >= 0; i--)
			{
				switch (args[i])
				{
					case SKeycode.Control:
						key += KEY_CTRL;
						break;
					case SKeycode.Alt:
						key += KEY_ALT;
						break;
					case SKeycode.Shift:
						key += KEY_SHIFT;
						break;
					default:
						warning("不支持其他键值:" + args[i]);
						break;
				}
			}
			return key;
		}
	}
}