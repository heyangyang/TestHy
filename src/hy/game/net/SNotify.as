package hy.game.net
{
	import hy.game.net.interfaces.INotify;
	import hy.game.utils.SDebug;

	public class SNotify implements INotify
	{
		public function SNotify()
		{
		}

		public function handleMessage(protocolId : uint, param : Object) : void
		{
		}

		protected function print(... args) : void
		{
			SDebug.print.apply(this, args);
		}

		protected function warning(... args) : void
		{
			SDebug.warning.apply(this, args);
		}

		protected function error(... args) : void
		{
			SDebug.error.apply(this, args);
		}

		/**
		 * 发送消息到服务器
		 * @param dataBase
		 *
		 */
		public function sendData(dataBase : SNetBaseData) : void
		{
			SGameSocket.instance.sendData(dataBase);
		}
	}
}