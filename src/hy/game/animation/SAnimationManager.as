package hy.game.animation
{
	import flash.system.System;
	import flash.utils.Dictionary;
	
	import hy.game.manager.SBaseManager;

	/**
	 *
	 * 动画管理器
	 *
	 */
	public class SAnimationManager extends SBaseManager
	{
		private static var instance : SAnimationManager;

		public static function getInstance() : SAnimationManager
		{
			if (!instance)
				instance = new SAnimationManager();
			return instance;
		}

		public function SAnimationManager()
		{
			if (instance)
				error("instance != null");
		}

		/**
		 * 根据动画id得到动画描述符的映射
		 */
		private var m_animationDescriptionById : Dictionary = new Dictionary(false);

		/**
		 * 获取动画描述
		 * @param id
		 * @return
		 *
		 */
		public function getAnimationDescription(id : String) : SAnimationDescription
		{
			if (!id)
				return null;
			id = id.toLowerCase();
			return m_animationDescriptionById[id];
		}

		/**
		 * 添加批动画描述符
		 */
		public function addBatchAnimationDescription(xml : XML, width : int, height : int, version : String = null) : void
		{
			parseAnimations(xml, width, height, m_animationDescriptionById, version);
			System.disposeXML(xml);
		}

		public function parseAnimations(xml : XML, width : int, height : int, animationDescriptionById : Dictionary, version : String = null) : void
		{
			if (!xml)
				return;

			for each (var animationXML : XML in xml.animation)
			{
				parseAnimation(animationXML, width, height, animationDescriptionById, version);
			}
		}

		/**
		 * 解析动画描述文件
		 * @param animationXML  frame0,-35,-92 (-35,-92分别为x,y基于centerX,centerY的偏移数据）
		 * <animation id="effect/revive.swf" resourceId="efect/revive.swf"
		 * frames="frame0,-35,-92;frame1,-69,-90" durations="120,120" centerX="200" centerY="251"/>
		 * @return
		 */
		private function parseAnimation(animationXML : XML, width : int, height : int, animationDescriptionById : Dictionary = null, version : String = null) : SAnimationDescription
		{
			if (!animationXML)
				return null;

			var desc : SAnimationDescription = new SAnimationDescription();
			desc.id = String(animationXML.@id).toLowerCase();
			desc.url = String(animationXML.@url);
			desc.totalFrame = int(animationXML.@totalFrame);
			desc.centerX = int(animationXML.@centerX);
			desc.centerY = int(animationXML.@centerY);
			var animationWidth : int = int(animationXML.@width);
			var animationHeight : int = int(animationXML.@height);
			if (animationWidth > 0 && animationHeight > 0)
			{
				desc.width = animationWidth;
				desc.height = animationHeight;
			}
			else
			{
				desc.width = width;
				desc.height = height;
			}
			desc.version = String(animationXML.@version);
			desc.blendMode = String(animationXML.@blendMode);

			desc.depth = animationXML.@depth;
			desc.autorotation = Boolean(animationXML.@autorotation);
			desc.loops = int(animationXML.@loops);

			var mainVersion : String = version || String(animationXML.@version);
			if (!desc.version || desc.version == "undefined")
				desc.version = mainVersion;

			var frameDescription : SFrameDescription;
			var frameValue : String;
			for each (var frame : XML in animationXML.frame)
			{
				frameDescription = new SFrameDescription();
				frameDescription.index = uint(frame.@index);
				frameValue = frame.@frame;
				if (frameValue)
					frameDescription.frame = uint(frameValue);
				else
					frameDescription.frame = frameDescription.index;
				frameDescription.duration = uint(frame.@duration);
				frameDescription.offsetX = int(frame.@offsetX);
				frameDescription.offsetY = int(frame.@offsetY);
				desc.frameDescriptionByIndex[frameDescription.index] = frameDescription;
			}
			if (animationDescriptionById)
				animationDescriptionById[desc.id] = desc;
			return desc;
		}

		/**
		 * 创建动画
		 * animationId后面添加用来区分动画ID与资源ID，比如武器反转时需要ID与动画ID不同
		 */
		/**
		 * 创建Animation
		 * @param id 动画ID
		 * @animationId 资源ID，如果动画ID与资源ID可能不同，则传入参数，如果为空则使用id
		 * @param otherIds 其他方向ID
		 * @param saveAnimation 是否将动画保存
		 * @param priority 下载优先级
		 * @param needReversal 是否要反转
		 */
		public function createAnimation(resId : String, animationId : String = null, needReversal : Boolean = false) : SAnimationResource
		{
			var animation : SAnimationResource;
			animationId = animationId || resId;
			var desc : SAnimationDescription = m_animationDescriptionById[animationId];

			if (desc)
			{
				animation = new SAnimationResource(resId, desc, needReversal);
				return animation;
			}
			else
			{
				//(this, "动画资源" + resId + "对应的动画描述" + animationId + "不存在！");
			}
			return null;
		}
	}
}