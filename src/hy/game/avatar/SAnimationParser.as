package hy.game.avatar
{
	import flash.utils.Dictionary;


	/**
	 *
	 * 动画解析器
	 *
	 */
	public class SAnimationParser
	{
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
		public function parseAnimation(animationXML : XML, width : int, height : int, animationDescriptionById : Dictionary = null, version : String = null) : SAnimationDescription
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

			for each (var frame : XML in animationXML.frame)
			{
				var frameDescription : SFrameDescription = new SFrameDescription();
				frameDescription.index = uint(frame.@index);
				var frameValue : String = frame.@frame;
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
	}
}