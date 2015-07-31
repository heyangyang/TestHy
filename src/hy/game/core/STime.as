package hy.game.core
{


	public class STime
	{
		/**
		 * 从游戏开始到到现在所用的时间
		 */
		public static var time : int;
		/**
		 * 传递时间的缩放。这可以用于减慢运动效果
		 */
		public static var timeScale : Number;

		public static var getTimer : int;

		/**
		 * 每帧间隔时间
		 */
		public static var deltaTime : int;
		/**
		 * 当前帧所耗时间
		 */
		public static var passedTime : int;

		public function STime()
		{
		}
	}
}