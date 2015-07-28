package hy.game.avatar
{

	/**
	 *
	 * 动画帧描述
	 *
	 */
	public class SFrameDescription
	{
		/**
		 * 动画帧的持续时间
		 */
		public var duration : uint;

		/**
		 * 动画帧的序号，从1开始
		 */
		public var index : uint;
		public var frame : uint;

		/**
		 * 动画帧的x偏移，为中心点相对最小包围框左上角的偏移
		 */
		public var x : int;
		public var offsetX : int;

		/**
		 * 动画帧的y偏移，为中心点相对最小包围框左上角的偏移
		 */
		public var y : int;
		public var offsetY : int;

		public function SFrameDescription()
		{
		}
	}
}