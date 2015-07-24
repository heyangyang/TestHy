package hy.game.cfg
{
	import flash.display.Stage;
	import flash.geom.Rectangle;

	public class Config
	{
		/**
		 * 当前游戏帧率
		 */
		public static var frameRate : int = 60;

		/**
		 * 最大的回收
		 */
		public static const RECYCLE_MEMORY_MAX : int = 20;

		/**
		 * 舞台
		 */
		public static var stage : Stage;
		/**
		 * 资源根目录
		 */
		public static var webRoot : String = "..";
		/**
		 * 最大重复加载次数
		 */
		public static const MAX_RELOAD : int = 5;
		/**
		 * 是否支持Gpu加速
		 */
		public static var supportDirectX : Boolean = false;

		public function Config()
		{
		}
	}
}