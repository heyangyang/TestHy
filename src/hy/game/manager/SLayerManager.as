package hy.game.manager
{
	import flash.display.Stage;
	import flash.events.Event;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;

	import hy.game.cfg.Time;
	import hy.game.core.GameContainer;
	import hy.game.core.interfaces.IGameContainer;
	import hy.game.enum.PriorityType;
	import hy.game.namespaces.name_part;

	use namespace name_part;

	/**
	 * 层级管理器
	 * @author hyy
	 *
	 */
	public class SLayerManager extends SBaseManager
	{
		public static const LAYER_MAP : String = "map";
		public static const LAYER_GAME : String = "game";
		public static const LAYER_WEATHER : String = "weather";
		public static const LAYER_UI : String = "ui";
		public static const LAYER_ALERT : String = "alert";
		public static const LAYER_GUIDE : String = "guide";

		private static var instance : SLayerManager;

		public static function getInstance() : SLayerManager
		{
			if (instance == null)
			{
				instance = new SLayerManager();
			}
			return instance;
		}

		private var m_list : Vector.<IGameContainer>;
		private var m_dictionary : Dictionary;
		private var m_stage : Stage;
		private var m_needSort : Boolean;
		private var elapsedTime : int;
		private var passedTime : int;

		public function SLayerManager()
		{
		}

		public function init(stage : Stage) : void
		{
			if (stage == null)
				error("stage==null");
			m_stage = stage;
			m_list = new Vector.<IGameContainer>();
			m_dictionary = new Dictionary();
			//添加默认层级
			addLayer(LAYER_MAP, PriorityType.PRIORITY_MAX);
			addLayer(LAYER_GAME, PriorityType.PRIORITY_MAX);
			addLayer(LAYER_WEATHER, PriorityType.PRIORITY_MAX);
			addLayer(LAYER_UI, PriorityType.PRIORITY_MAX);
			addLayer(LAYER_ALERT, PriorityType.PRIORITY_MAX);
			addLayer(LAYER_GUIDE, PriorityType.PRIORITY_MAX);
			start();
		}

		private function addLayer(tag : String, priority : int) : void
		{
			if (m_dictionary[tag])
				error(this, tag, "is exists");
			var gameContainer : IGameContainer = new GameContainer();
			gameContainer.tag = tag;
			gameContainer.priority = priority;
			m_stage.addChild(gameContainer as GameContainer);
			m_list.push(gameContainer);
			m_dictionary[tag] = gameContainer;
			m_needSort = true;
		}

		private function start() : void
		{
			elapsedTime = getTimer();
			m_stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}

		private function onEnterFrame(evt : Event) : void
		{
			Time.deltaTime = getTimer() - elapsedTime;
			passedTime = elapsedTime = getTimer();
			m_needSort && onSort();
			for (var i : int = m_list.length - 1; i >= 0; i--)
			{
				m_list[i].update();
			}
			Time.passedTime = getTimer() - passedTime;
		}

		private function onSort() : void
		{
			m_list.sort("priority");
			m_needSort = false;
		}
	}
}