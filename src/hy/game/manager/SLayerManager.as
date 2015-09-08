package hy.game.manager
{
	import flash.display.Stage;
	import flash.utils.Dictionary;
	
	import hy.game.cfg.Config;
	import hy.game.interfaces.display.IDisplayContainer;
	import hy.game.interfaces.display.IDisplayObject;
	import hy.game.namespaces.name_part;
	import hy.game.render.SDirectContainer;
	import hy.game.render.SRenderContainer;
	import hy.game.stage3D.SStage3D;

	use namespace name_part;

	/**
	 * 层级管理器
	 * @author hyy
	 *
	 */
	public class SLayerManager extends SBaseManager
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

		private var mRenderDictionary : Dictionary;
		private var mStage : Stage;
		private var mIndex : int;

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
			mRenderDictionary = new Dictionary();
			//添加默认层级
			addLayer(LAYER_MAP, createContainer());
			addLayer(LAYER_EFFECT_BOTTOM, createContainer());
			addLayer(LAYER_ENTITY, createContainer());
			addLayer(LAYER_EFFECT_TOP, createContainer());
			addLayer(LAYER_NAME, createContainer());
			addLayer(LAYER_HP, createContainer());
			addLayer(LAYER_OTHER, createContainer());
			addLayer(LAYER_WEATHER, createContainer());
			addLayer(LAYER_UI, new SRenderContainer());
			addLayer(LAYER_ALERT, new SRenderContainer());

			function createContainer() : IDisplayContainer
			{
				if (Config.supportDirectX)
					return new SDirectContainer();
				return new SRenderContainer();
			}
		}

		/**
		 * 添加容器
		 * @param tag
		 * @param container
		 *
		 */
		private function addLayer(tag : String, container : IDisplayContainer) : void
		{
			container.layer = mIndex++;
			if (mRenderDictionary[tag])
				error(this, tag, "is exists");
			if (container is SRenderContainer)
				mStage.addChild(container as SRenderContainer);
			else
				SStage3D.stage.addDisplay(container as SDirectContainer);
			mRenderDictionary[tag] = container;
		}

		public function getLayer(tag : String) : IDisplayContainer
		{
			return mRenderDictionary[tag];
		}

		/**
		 * 根据类型添加显示对象
		 * @param type
		 * @param render
		 *
		 */
		public function addChild(type : String, render : IDisplayObject) : void
		{
			var parent : IDisplayContainer = mRenderDictionary[type];
			if (!parent)
			{
				error("layer is not find :" + type);
				return;
			}
			parent.addDisplay(render);
		}
	}
}