package hy.game.utils
{
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.KeyboardEvent;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;


	/**
	 * 屏幕打印
	 * @author hyy
	 *
	 */
	public class SDebug extends Sprite
	{
		public static var TRACE_INFO : Boolean = false;
		public static var TRACE_WARN : Boolean = true;
		public static var TRACE_ERROR : Boolean = true;
		/**
		 * 输入文本
		 */
		private var inputTxt : TextField;
		/**
		 * -----------------------------------------------功能配置-------------------------------------------------------
		 * 屏幕打印解锁密码
		 */
		public static var PASS_WORD : String = "PABCD";
		/**
		 * 最多显示行数
		 */
		public static var MAX_LINE_COUNT : int = 37;

		/**
		 * 连接符
		 */
		public static const SPLITTER : String = "\t";

		/**
		 * 字体大小
		 */
		public static var fontSize : int = 12;

		/**
		 * 字体样式
		 */
		public static var fontFamily : String = "Lucida Sans Unicode";

		/**
		 * 行距
		 */
		public static var lineSpacing : int = 1;

		/**
		 * 背景颜色
		 */
		public static var backgroundColor : int = 0x000000;

		/**
		 * 背景透明度
		 */
		public static var backgroundAlpha : Number = 0;

		/**
		 * 默认启动打印屏幕
		 */
		public static var defaultStart : Boolean = false;

		/**
		 * 隐藏后是否保存信息
		 */
		public static var saveOnHide : Boolean = true;

		/**
		 * ----------------------------------------------颜色配置-----------------------------------------------------
		 * 一般信息颜色
		 */
		public static const NORMAL_INFOR_COLOR : int = 0xFFFFFF;
		/**
		 * SOCKET信息颜色
		 */
		public static const SOCKET_INFOR_COLOR : int = 0xFFFF00;
		/**
		 * 错误信息颜色
		 */
		public static const ERROR_INFOR_COLOR : int = 0xFF0000;
		/**
		 * 警告颜色
		 */
		public static const WARN_INFOR_COLOR : int = 0xFFFF00;
		/**
		 * 描黑滤镜
		 */
		public static var blackFilters : Array = [new GlowFilter(0x000000, 1, 2, 2, 255)];
		/**
		 * 输出文本
		 */
		private var printField : TextField;
		private var _infor : String = "";
		/**
		 * 如果输入的字符和PASS_WORD的第一个数字一样，则重新开始记录输入
		 * 看输入是否和PASS_WORD一样。一样则开启打印
		 */
		private var startRecord : Boolean;
		/**
		 * 输入的字母
		 */
		private var inputWords : String = "";
		/**
		 * 是否可以使用
		 */
		private var isAvailable : Boolean;
		/**
		 * 显示容器
		 */
		private var container : Stage;

		/**
		 * ----------------------------------------------静态方法------------------------------------------------------
		 */
		private static var _instance : SDebug;

		/**
		 * 初始化设置舞台后才能使用
		 * @param	state
		 */
		public static function init(stage : Stage) : SDebug
		{
			if (!_instance)
			{
				_instance = new SDebug(stage);
			}
			return _instance;
		}

		public function SDebug(stage : Stage) : void
		{
			this.container = stage;
			this.init();
		}

		/**
		 * 初始化
		 */
		private function init() : void
		{
			this.graphics.beginFill(backgroundColor, backgroundAlpha);
			this.graphics.drawRect(0, 0, container.stageWidth, container.stageHeight);
			this.graphics.endFill();

			this.mouseEnabled = false;
			this.mouseChildren = false;

			printField = new TextField();
			printField.width = container.stageWidth;
			printField.height = container.stageHeight;
			printField.selectable = false;
			printField.mouseEnabled = false;
			printField.wordWrap = true;
			printField.text = "";
			printField.filters = blackFilters;

			this.addChild(printField);

			inputTxt = new TextField();
			var format : TextFormat = new TextFormat();
			format.size = 14;
			format.bold = true;
			format.font = "宋体";
			inputTxt.defaultTextFormat = format;
			inputTxt.background = true;
			inputTxt.backgroundColor = 0x000000;
			inputTxt.textColor = 0xffffff;
			inputTxt.type = TextFieldType.INPUT;
			inputTxt.width = container.stageWidth * .5;
			inputTxt.height = 20;
			inputTxt.x = (container.stageWidth - inputTxt.width) * .5;
			inputTxt.y = (container.stageHeight - 100)
			inputTxt.wordWrap = true;
			this.addChild(inputTxt);
			inputTxt.visible = false;
			inputTxt.alpha = 0.6;
			inputTxt.filters = blackFilters;

			container.addEventListener(KeyboardEvent.KEY_UP, keyUpHandler, false, 0, true);

			if (defaultStart)
			{
				showPrinter();
			}
		}

		/**
		 * 键盘事件
		 * @param	e
		 */
		private function keyUpHandler(e : KeyboardEvent) : void
		{
			switch (e.keyCode)
			{
				case SKeycode.Esc:
					hidePrinter();
					break;
				case SKeycode.Delete:
					clearPrinter();
					break;
			}
			checkShowPriner(e.keyCode);
		}

		/**
		 * 打印对象
		 * @param	target		对象主体
		 * @param	delimiter	划分格式
		 * @return
		 */
		public static function printObject(target : Object, delimiter : String = "") : String
		{
			var obj : Object;
			var str : String = "\n";
			var objStr : String = "";

			for (var key : String in target)
			{
				objStr = "";
				obj = target[key];

				if (!(obj is int || obj is String || obj is Number || obj is uint))
				{
					objStr = printObject(obj, delimiter + "\t");
				}
				str += delimiter + key + " => " + objStr + "\n";
			}

			str = str.replace(/(\n){2}/g, "$1");
			return str;
		}

		/**
		 * SOCKET打印
		 * @param	...arg
		 */
		public static function socketPrint(... arg) : void
		{
			write(arg, SOCKET_INFOR_COLOR);
		}

		/**
		 * 错误信息打印
		 * @param	...arg
		 */
		public static function error(... arg) : void
		{
			TRACE_ERROR && trace("[error] " + arg.join(" "))
			write(arg, ERROR_INFOR_COLOR);
		}

		/**
		 * 警告
		 * @param arg
		 *
		 */
		public static function warning(... arg) : void
		{
			TRACE_WARN && trace("[warn] " + arg.join(" "))
			write(arg, WARN_INFOR_COLOR);
		}

		/**
		 * 普通打印
		 * @param	...arg
		 */
		public static function print(... arg) : void
		{
			TRACE_INFO && trace("[info] " + arg.join(" "))
			write(arg, NORMAL_INFOR_COLOR);
		}

		/**
		 * 替换打印
		 * @param arg
		 * printf("aaa,%d,hi",bbb) 输出 aaa,bbb,hi
		 */
		public static function printf(str : String, ... arg) : String
		{
			for each (var tmp : String in arg)
			{
				str = str.replace("%d", tmp);
			}
			return str;
		}

		/**
		 * 屏幕打印
		 * @param	inforList	信息列表
		 * @param	color		颜色
		 */
		private static function write(inforList : Array, color : int) : void
		{
			if (!_instance)
			{
				throw(new Error("打印器没有初始化，应该先初始化设置舞台后方能使用！"));
				return;
			}

			var infor : String = inforList.join(SPLITTER);
			_instance.write("<font color='#" + color.toString(16) + "'>\\&gt;" + infor + "</font>");
		}

		/*************************************类属性方法************************************************/

		/**
		 * 测试
		 * @param	...arg
		 */
		public function write(infor : String) : void
		{
			if (!isAvailable && !saveOnHide)
			{
				return;
			}

			_infor += infor + "\n";

			if (printField.numLines > MAX_LINE_COUNT)
			{
				_infor = _infor.replace(/.*\n/, "");
			}
			printField.htmlText = formatText(_infor);
		}

		/**
		 * 格式化文本
		 * @param	content
		 * @return
		 */
		private function formatText(content : String) : String
		{
			var left : String = "<font face='" + fontFamily + "' size='";
			left += fontSize + "'><textFormat leading='";
			left += lineSpacing + "'>";
			return left + content + "</textFormat></font>";
		}

		/**
		 * 检测是否开启打印
		 * @param keyCode
		 *
		 */
		private function checkShowPriner(keyCode : uint) : void
		{
			if (!startRecord && keyCode == PASS_WORD.charCodeAt(0))
			{
				startRecord = true;
				inputWords = "";
			}

			if (startRecord && inputWords.length < PASS_WORD.length)
			{
				inputWords += String.fromCharCode(keyCode);

				if (inputWords == PASS_WORD)
					showPrinter();
				return;
			}
			startRecord = false;
		}

		/**
		 * 清空打印屏幕
		 */
		private function clearPrinter() : void
		{
			_infor = "";
			printField.htmlText = "";
		}

		/**
		 * 显示打印机
		 */
		private function showPrinter() : void
		{
			isAvailable = true;

			if (parent == null)
			{
				container.addChild(this);
			}
		}

		/**
		 * 隐藏打印机
		 */
		private function hidePrinter() : void
		{
			isAvailable = false;
			!saveOnHide && clearPrinter();
			parent && parent.removeChild(this);
		}

	}

}