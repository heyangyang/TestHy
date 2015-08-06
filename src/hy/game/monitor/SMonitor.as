package hy.game.monitor
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.system.Capabilities;
	import flash.system.System;
	import flash.text.StyleSheet;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	
	import hy.game.cfg.Config;
	import hy.game.core.STime;
	import hy.game.core.SUpdate;
	import hy.game.enum.EnumPriority;
	import hy.rpg.utils.UtilsCommon;
	import hy.rpg.utils.UtilsFilter;
	import hy.rpg.utils.UtilsUIStyle;


	/**
	 *
	 * 监视器
	 *
	 */
	public class SMonitor extends SUpdate
	{
		public static const DEFAULT_UPDATE_RATE : Number = 2;
		private static const DEFAULT_BACKGROUND : uint = 0x66000000;
		private static const DEFAULT_COLOR : uint = 0xffffffff;

		private static var instance : SMonitor = null;

		public static function getInstance() : SMonitor
		{
			if (!instance)
				instance = new SMonitor();
			return instance;
		}

		private var container : Sprite;

		private var defaultColor : uint = DEFAULT_COLOR;

		private var updateRate : Number = 0.;

		/**
		 * 帧数由<code>diagram</code>中更新的FPS值决定.
		 * @see #diagram
		 */
		private var fpsUpdatePeriod : int = 10;

		/**
		 * 帧数由<code>diagram</code>中更新的MS值决定.
		 * @see #diagram
		 */
		private var timerUpdatePeriod : int = 10;

		private var intervalId : int = 0;

		private var targets : Dictionary = new Dictionary();
		private var xml : XML;

		private var style : StyleSheet = new StyleSheet();
		private var label : TextField;

		private var numFrames : int = 0;
		private var updateTime : int = 0;
		private var framerate : Number = 0.0;
		private var maxMemory : int = 0;

		private var background : uint = DEFAULT_BACKGROUND;

		private var shape : Shape;
		private var bitmap : Bitmap;
		private var isDebug : Boolean = true;

		private var fpsUpdateCounter : int;
		private var previousFrameTime : int;
		private var previousPeriodTime : int;

		/**
		 * Create a new Monitor object.
		 * @param myUpdateRate The number of update per second the monitor will perform.
		 *
		 */
		public function SMonitor(rate : Number = DEFAULT_UPDATE_RATE)
		{
			super();

			updateRate = rate;

			xml = <monitor>
					<copyright/>
					<header/>
					<version/>
					<framerate>framerate:</framerate>
					<memory>memory:</memory>
				</monitor>;
			// diagram initialization
			setStyle("monitor", {fontSize: "14px", fontFamily: UtilsUIStyle.TEXT_FONT, leading: "2px"});
			//FPS(FPS:)
			setStyle("framerate", {color: "#CCCCCC", fontFamily: UtilsUIStyle.TEXT_FONT, fontSize: 14, leading: 2});
			//Frame time - time of frame(TME:)
			setStyle("frameTime", {color: "#CCCCCC", fontFamily: UtilsUIStyle.TEXT_FONT, fontSize: 14, leading: 2});
			//Time of method performing - time of method execution(MS:)
			setStyle("methodTime", {color: "#0066FF", fontFamily: UtilsUIStyle.TEXT_FONT, fontSize: 14, leading: 2});
			//Memory(MEM:)
			setStyle("memory", {color: "#CCCC00", fontFamily: UtilsUIStyle.TEXT_FONT, fontSize: 14, leading: 2});

			setStyle("copyright", {color: "#999999", fontFamily: UtilsUIStyle.TEXT_FONT, fontSize: 14, leading: 2});
			setStyle("version", {color: "#999999", fontFamily: UtilsUIStyle.TEXT_FONT, fontSize: 14, leading: 2});
			setStyle("header", {color: "#999999", fontFamily: UtilsUIStyle.TEXT_FONT, fontSize: 14, leading: 2});

			xml.copyright = Config.VERSION;
			xml.version = Capabilities.version + (Capabilities.isDebugger ? " (debug)" : "");

			container = new Sprite();
			container.mouseEnabled = false;
			container.mouseChildren = false;
			container.y = container.x = 0;
			initView();
		}

		override public function registerd(priority : int = EnumPriority.PRIORITY_0) : void
		{
			super.registerd(priority);
			Config.stage.addChild(container);
			Config.stage.addChild(bitmap);
		}

		override public function unRegisterd() : void
		{
			super.unRegisterd();
			container.parent && container.parent.removeChild(container);
			bitmap.parent && bitmap.parent.removeChild(bitmap);
		}

		private function initView() : void
		{
			label = new TextField();
			label.styleSheet = style;
			label.condenseWhite = true;
			label.selectable = false;
			label.mouseEnabled = false;
			label.mouseWheelEnabled = false;
			label.autoSize = TextFieldAutoSize.LEFT;
			label.filters = UtilsFilter.blackFilters;
			label.x = 2;
			label.y = 2;
			container.addChild(label);


			if (isDebug)
			{
				shape = new Shape();
				bitmap = new Bitmap(new BitmapData(100, 100, false, 0x0));
			}
		}

		public function setStyle(styleName : String, value : Object) : void
		{
			style.setStyle(styleName, value);
		}

		private function updateDiagram() : void
		{
			++numFrames;

			var value : Number;
			var mod : int;
			var time : int = getTimer();
			var stageFrameRate : int = Config.frameRate;

			// FPS text
			if (++fpsUpdateCounter == fpsUpdatePeriod)
			{
				value = 1000 * fpsUpdatePeriod / (time - previousPeriodTime);
				if (value > stageFrameRate)
					value = stageFrameRate;
				mod = value * 100 % 100;
				xml.framerate = "FPS: " + int(value) + "." + ((mod >= 10) ? mod : ((mod > 0) ? ("0" + mod) : "00"));
				value = 1000 / value;
				mod = value * 100 % 100;
				xml.frameTime = "TME: " + int(value) + "." + ((mod >= 10) ? mod : ((mod > 0) ? ("0" + mod) : "00"));
				previousPeriodTime = time;
				fpsUpdateCounter = 0;
			}

			// FPS plot
			if ((time - updateTime) >= 1000 / updateRate)
			{
				if (!container.visible || !container.stage)
				{
					updateTime = time;
					numFrames = 0;
					return;
				}
				// framerate
				framerate = numFrames / ((time - updateTime) / 1000);


				value = 1000 / (time - previousFrameTime);
				if (value > stageFrameRate)
					value = stageFrameRate;

				previousFrameTime = time;

				// memory
				maxMemory = System.totalMemory;
				xml.memory = "MEM: " + UtilsCommon.bytesToString(maxMemory);

				// properties
				var properties : Array;
				var numProperties : int;
				var property : String;
				var text : String;
				var object : Object;
				var scaledValue : Number;

				for (var target : Object in targets)
				{
					properties = targets[target];
					numProperties = properties.length;

					for (var i : int = 0; i < numProperties; ++i)
					{
						property = properties[i].property;
						text = properties[i].label;
						object = target[property];
						xml[text] = text + ": " + object;
					}
				}

				numFrames = 0;
				updateTime = time;

				if (container.stage)
				{
					label.htmlText = xml;
					updateBackground();
				}
			}
		}

		/**
		 * Watch a property of a specified object.
		 *
		 * @param myTarget The object containing the property to watch.
		 * @param myProperty The name of the property to watch.
		 * @param myColor The color of the displayed label/chart.
		 * @param myScale The scale used to display the chart. Use "0" to disable the chart.
		 * @param myOverflow If true, the modulo operator is used to make
		 * sure the value can be drawn on the chart.
		 */
		public function watchProperty(target : Object, property : String, label : String, color : int) : SMonitor
		{
			if (!targets[target])
				targets[target] = new Array();


			targets[target].push({property: property, label: label});

			var object : Object = target[property];
			if (object is int)
				object = formatInt(object as int);

			xml[label] = label + ": " + object;

			style.setStyle(label, {color: "#" + (color & 0xffffff).toString(16), fontFamily: UtilsUIStyle.TEXT_FONT, fontSize: 14, leading: 2});

			return this;
		}

		private function updateBackground() : void
		{
			if (label.textWidth == container.width && label.textHeight == container.height)
				return;

			container.graphics.clear();
			container.graphics.beginFill(background & 0xffffff, 1);
			container.graphics.drawRect(0, 0, container.width, container.height);
			container.graphics.endFill();
			bitmap.y = container.height;
		}

		private function formatInt(num : int) : String
		{
			var n : int;
			var s : String;
			if (num < 1000)
			{
				return "" + num;
			}
			else if (num < 1000000)
			{
				n = num % 1000;
				if (n < 10)
				{
					s = "00" + n;
				}
				else if (n < 100)
				{
					s = "0" + n;
				}
				else
				{
					s = "" + n;
				}
				return int(num / 1000) + " " + s;
			}
			else
			{
				n = (num % 1000000) / 1000;
				if (n < 10)
				{
					s = "00" + n;
				}
				else if (n < 100)
				{
					s = "0" + n;
				}
				else
				{
					s = "" + n;
				}
				n = num % 1000;
				if (n < 10)
				{
					s += " 00" + n;
				}
				else if (n < 100)
				{
					s += " 0" + n;
				}
				else
				{
					s += " " + n;
				}
				return int(num / 1000000) + " " + s;
			}
		}



		override public function update() : void
		{
			updateDiagram();

			// Animate spinner
			if (shape && bitmap)
			{
				// Fade to black
				shape.graphics.clear();
				shape.graphics.beginFill(0x0, 0.05);
				shape.graphics.drawRect(0, 0, 100, 100);
				bitmap.bitmapData.draw(shape);
				// Draw red circle/line
				shape.graphics.clear();
				shape.graphics.lineStyle(3, 0x00ff00, 1, true);
				shape.graphics.drawCircle(50, 50, 46);
				shape.graphics.moveTo(50, 50);
				shape.graphics.lineTo(50 + 45 * Math.cos(STime.getTimer / 300), 50 + 45 * Math.sin(STime.getTimer / 300));
				bitmap.bitmapData.draw(shape);
			}
		}


		override public function destroy() : void
		{
			if (container && container.parent)
				container.parent.removeChild(container);
			super.destroy();
		}
	}
}