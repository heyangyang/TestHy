package hy.game.manager
{
	import flash.display.Stage;
	import flash.events.Event;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	
	import hy.game.core.GameContainer;
	import hy.game.core.GameObject;
	import hy.game.core.STime;
	import hy.game.core.interfaces.IGameContainer;
	import hy.game.enum.EnumPriority;
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
				instance = new SLayerManager();
			return instance;
		}

		private var m_list : Vector.<IGameContainer>;
		private var m_dictionary : Dictionary;
		private var m_stage : Stage;
		private var m_needSort : Boolean;
		private var m_elapsedTime : int;

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
			addLayer(LAYER_MAP, EnumPriority.PRIORITY_9);
			addLayer(LAYER_GAME, EnumPriority.PRIORITY_8);
			addLayer(LAYER_WEATHER, EnumPriority.PRIORITY_7);
			addLayer(LAYER_UI, EnumPriority.PRIORITY_6);
			addLayer(LAYER_ALERT, EnumPriority.PRIORITY_5);
			addLayer(LAYER_GUIDE, EnumPriority.PRIORITY_4);
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
			m_elapsedTime = getTimer();
			m_stage.addEventListener(Event.ENTER_FRAME, onEnterFrame, false, 999);
		}

		private function onEnterFrame(evt : Event) : void
		{
			STime.getTimer = getTimer();
			STime.deltaTime = STime.getTimer - m_elapsedTime;
			m_elapsedTime = STime.getTimer;
			m_needSort && onSort();
			for (var i : int = m_list.length - 1; i >= 0; i--)
			{
				m_list[i].update();
			}
		}

		private function onSort() : void
		{
			m_list.sort(onPrioritySortFun);
			m_needSort = false;
		}

		private function onPrioritySortFun(a : IGameContainer, b : IGameContainer) : int
		{
			if (a.priority > b.priority)
				return 1;
			if (a.priority < b.priority)
				return -1;
			return 0;
		}

		public function addObjectByType(type : String, object : GameObject) : void
		{
			var gameContainer : IGameContainer = m_dictionary[type];
			if (!gameContainer)
			{
				error("layer is not find :" + type);
				return;
			}
			object.owner = gameContainer;
		}
	}
}