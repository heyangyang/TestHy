package hy.game.net
{
	import flash.utils.Dictionary;

	/**
	 * 客户端和服务器消息
	 * @author hyy
	 *
	 */
	public class SCCommand
	{
		public static var cmdData : Dictionary = new Dictionary()

		public function SCCommand()
		{
		}

		public static function init() : void
		{
		}

		public static function getClassByModule(module : int) : Class
		{
			return cmdData[module];
		}
	}
}
