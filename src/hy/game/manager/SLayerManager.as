package hy.game.manager
{
	import flash.display.DisplayObject;
	import flash.display.Stage;
	import flash.utils.Dictionary;

	import hy.game.cfg.Config;
	import hy.game.core.GameContainer;
	import hy.game.core.GameObject;
	import hy.game.core.interfaces.IContainer;
	import hy.game.core.interfaces.IEnterFrame;
	import hy.game.core.interfaces.IGameContainer;
	import hy.game.enum.EnumPriority;
	import hy.game.namespaces.name_part;
	import hy.game.render.SDirectContainer;
	import hy.game.render.SRender;
	import hy.game.render.SRenderContainer;
	import hy.game.stage3D.SStage3D;

	use namespace name_part;

	/**
	 * 层级管理器
	 * @author hyy
	 *
	 */
	public class SLayerManager extends SBaseManager implements IEnterFrame
	{
		public static const LAYER_MAP : String = "1_map";
		public static const LAYER_EFFECT_BOTTOM : String = "2_effect_bottom";
		public static const LAYER_ENTITY : String = "3_entity";
		public static const LAYER_EFFECT_TOP : String = "4_effect_top";
		public static const LAYER_NAME : String = "5_name";
		public static const LAYER_HP : String = "5_hp";
		public static const LAYER_OTHER : String = "6_other";
		public static const LAYER_WEATHER : String = "7_weather";
		public static const LAYER_UI : String = "8_ui";
		public static const LAYER_ALERT : String = "9_alert";

		private static var instance : SLayerManager;

		public static function getInstance() : SLayerManager
		{
			if (instance == null)
				instance = new SLayerManager();
			return instance;
		}

		private var mList : Vector.<IGameContainer>;
		private var mDictionary : Dictionary;
		private var mStage : Stage;
		private var mNeedSort : Boolean;


		public function SLayerManager()
		{
			if (instance)
				error("instance != null");
		}

		public function init(stage : Stage) : void
		{
			if (stage == null)
				error("stage==null");
			mStage = stage;
			mList = new Vector.<IGameContainer>();
			mDictionary = new Dictionary();
			//添加默认层级
			addLayer(LAYER_MAP, EnumPriority.PRIORITY_9, createContainer());
			addLayer(LAYER_EFFECT_BOTTOM, EnumPriority.PRIORITY_8, createContainer());
			addLayer(LAYER_ENTITY, EnumPriority.PRIORITY_8, createContainer());
			addLayer(LAYER_EFFECT_TOP, EnumPriority.PRIORITY_8, createContainer());
			addLayer(LAYER_NAME, EnumPriority.PRIORITY_8, createContainer());
			addLayer(LAYER_HP, EnumPriority.PRIORITY_8, createContainer());
			addLayer(LAYER_OTHER, EnumPriority.PRIORITY_7, createContainer());
			addLayer(LAYER_UI, EnumPriority.PRIORITY_6, new SRenderContainer());
			addLayer(LAYER_ALERT, EnumPriority.PRIORITY_5, new SRenderContainer());

			function createContainer() : IContainer
			{
				if (Config.supportDirectX)
					return new SDirectContainer();
				return new SRenderContainer();
			}
		}

		private function addLayer(tag : String, priority : int, container : IContainer) : void
		{
			if (mDictionary[tag])
				error(this, tag, "is exists");
			var gameContainer : IGameContainer = new GameContainer(container);
			gameContainer.tag = tag;
			gameContainer.priority = priority;
			if (gameContainer.container is SRenderContainer)
				mStage.addChild(gameContainer.container as DisplayObject);
			else
				SStage3D.stage.addChild(gameContainer.container as SDirectContainer);
			mList.push(gameContainer);
			mDictionary[tag] = gameContainer;
			mNeedSort = true;
		}

		public function update() : void
		{
			mNeedSort && onSort();
			for (var i : int = mList.length - 1; i >= 0; i--)
			{
				mList[i].update();
			}
		}

		private function onSort() : void
		{
			mList.sort(onPrioritySortFun);
			mNeedSort = false;
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
			var gameContainer : IGameContainer = mDictionary[type];
			if (!gameContainer)
			{
				error("layer is not find :" + type);
				return;
			}
			object.owner = gameContainer;
		}

		public function addRenderByType(type : String, render : SRender) : void
		{
			var gameContainer : IGameContainer = mDictionary[type];
			if (!gameContainer)
			{
				error("layer is not find :" + type);
				return;
			}
			gameContainer.addRender(render);
		}

		public function removeRenderByType(type : String, render : SRender) : void
		{
			var gameContainer : IGameContainer = mDictionary[type];
			if (!gameContainer)
			{
				error("layer is not find :" + type);
				return;
			}
			gameContainer.removeRender(render);
		}
	}
}