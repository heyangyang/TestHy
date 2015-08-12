package hy.game.cfg
{
	import flash.display.Stage;

	public class Config
	{
		/**
		 * 版本号
		 */
		public static var VERSION : String = "0.0.1";
		/**
		 * 是否调试模式
		 */
		public static var isDebug : Boolean = true;
		/**
		 * 分块宽度
		 */
		public static var TILE_WIDTH : int = 200;
		/**
		 * 分块高度
		 */
		public static var TILE_HEIGHT : int = 200;

		/**
		 * 格子宽度
		 */
		public static const GRID_WIDTH : int = 50;
		/**
		 * 格子高度
		 */
		public static const GRID_HEIGHT : int = 50;
		/**
		 * 小地图相对场景地图缩放比例
		 */
		public static const SMALL_MAP_SCALE : Number = 0.1;

		public static var BIG_MAP_SCALE : Number = 0.1;

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
		 * 屏幕的宽高
		 */
		public static var screenWidth : int;
		public static var screenHeight : int;
		/**
		 * 资源根目录
		 */
		public static var webRoot : String = ".";
		/**
		 * 最大重复加载次数
		 */
		public static const MAX_RELOAD : int = 5;
		/**
		 * 是否支持Gpu加速
		 */
		public static var supportDirectX : Boolean = true;

		public function Config()
		{
		}
	}
}