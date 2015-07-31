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
		private var golbal_dic : Dictionary;
		private var m_key : int;
		private var m_curDic : Dictionary;
		private var m_excuteFunction : Function;

		public function SKeyboardManager()
		{
			super();
			golbal_dic = new Dictionary();
		}

		public function init(stage : Stage) : void
		{
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDownHandler);
		}

		private function onKeyDownHandler(evt : KeyboardEvent) : void
		{
			m_key = 0;
			if (evt.ctrlKey)
				m_key += KEY_CTRL;
			if (evt.altKey)
				m_key += KEY_ALT;
			if (evt.shiftKey)
				m_key += KEY_SHIFT;
			m_curDic = golbal_dic[m_key];
			if (m_curDic == null)
				return;
			m_excuteFunction = m_curDic[evt.keyCode];
			m_excuteFunction != null && m_excuteFunction();
			m_excuteFunction = null;
		}

		public function addKeyDownHandler(fun : Function, keyCode : int, ... args) : void
		{
			if (fun == null)
			{
				error(this, "function is null!");
				return;
			}
			m_key = getKeyCode(args);
			if (keyCode == 0)
				return;
			m_curDic = golbal_dic[m_key];
			if (m_curDic == null)
				golbal_dic[m_key] = m_curDic = new Dictionary();
			if (m_curDic[keyCode])
				waring("key is exist : " + keyCode);
			m_curDic[keyCode] = fun;
		}

		public function removeKeyDownHandler(keyCode : uint, ... args) : void
		{
			if (keyCode == 0)
				return;
			m_key = getKeyCode(args);
			m_curDic = golbal_dic[m_key];
			if (!m_curDic)
				return;
			m_curDic[keyCode] = null;
			delete m_curDic[keyCode];
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
						waring("不支持其他键值:" + args[i]);
						break;
				}
			}
			return key;
		}
	}
}