package hy.game.manager
{
	import flash.display.Stage;
	import flash.utils.Dictionary;
	
	import hy.game.cfg.Config;
	import hy.game.core.interfaces.IContainer;
	import hy.game.core.interfaces.IEnterFrame;
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

		private var mList : Vector.<IContainer>;
		private var mRenderDictionary : Dictionary;
		private var mStage : Stage;


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
			mList = new Vector.<IContainer>();
			mRenderDictionary = new Dictionary();
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

		public function update() : void
		{
			for (var i : int = mList.length - 1; i >= 0; i--)
			{
				mList[i].update();
			}
		}

		private function addLayer(tag : String, priority : int, container : IContainer) : void
		{
			if (mRenderDictionary[tag])
				error(this, tag, "is exists");
			container.tag = tag;
			container.priority = priority;
			if (container is SRenderContainer)
				mStage.addChild(container as SRenderContainer);
			else
				SStage3D.stage.addChild(container as SDirectContainer);
			mList.push(container);
			mRenderDictionary[tag] = container;
		}

		public function push(type : String, render : SRender) : void
		{
			var gameContainer : IContainer = mRenderDictionary[type];
			if (!gameContainer)
			{
				error("layer is not find :" + type);
				return;
			}
			render.container = gameContainer;
			gameContainer.push(render);
		}

		public function remove(type : String, render : SRender) : void
		{
			var gameContainer : IContainer = mRenderDictionary[type];
			if (!gameContainer)
			{
				error("layer is not find :" + type);
				return;
			}
			render.container = null;
			gameContainer.remove(render);
		}
	}
}