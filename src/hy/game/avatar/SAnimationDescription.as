package hy.game.avatar
{
	import flash.display.BlendMode;
	import flash.filters.BitmapFilter;
	import flash.utils.Dictionary;

	/**
	 *
	 * 动画描述
	 *
	 */
	public class SAnimationDescription
	{
		/**
		 * 动画的id
		 */
		public var id : String;
		/**
		 * 该动画需要的资源
		 */
		public var url : String;
		public var totalFrame : int;

		public var centerX : int;
		public var centerY : int;

		/**
		 * 版本
		 */
		public var version : String;

		/**
		 * 渲染混合模式
		 */
		public var blendMode : String = BlendMode.NORMAL;

		/**
		 * 附带的滤镜
		 */
		public var filter : BitmapFilter;

		public var frameDescriptionByIndex : Dictionary = new Dictionary();

		/**
		 * 动画音效
		 */
		public var effectSound : String;

		/**
		 * 音乐持续次数
		 */
		public var soundLoops : int = 1;

		/**
		 * 该动画的宽度
		 */
		public var width : int;
		/**
		 * 该动画的高度
		 */
		public var height : int;

		/**
		 * 实现类似暴风雪的效果，在范围内随机位置创建多个动画(0代表不创建）
		 */
		public var rangeAnimations : int;

		/**
		 * 是否需要旋转（只针对飞行效果有效)0不需要，1需要
		 */
		public var autorotation : Boolean;

		/**
		 * 动画类型是放在是场景上还目标身上     0:目标  1:场景上
		 */
		public var animationType : int;

		/**
		 * 循环次数
		 */
		public var loops : int;

		/**
		 * 动画的层次关系  渲染深度的偏移值 身前1或身后-1
		 */
		public var depth : int;

		public function SAnimationDescription()
		{
			super();
		}

		public function getFrameDescriptionByIndex(index : uint) : SFrameDescription
		{
			return frameDescriptionByIndex[index];
		}
	}
}