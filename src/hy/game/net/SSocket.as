package hy.game.net
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.ObjectEncoding;
	import flash.net.Socket;
	import flash.utils.ByteArray;
	import flash.utils.Endian;

	import hy.game.manager.SObjectManager;

	/**
	 *
	 *
	 * 只负责传输二进制数据和解决半包粘包问题
	 *
	 * 不负责包结构解析
	 *
	 * 上行包结构：两个字节的包长+一个字节的包序+两个字节命令号(模块路由+方法路由)+具体的数据
	 *
	 * 下行包结构：两个字节的包长+两个字节命令号(模块路由+方法路由)+具体的数据
	 *
	 */
	public class SSocket extends Socket
	{
		private var mBytes : ByteArray;
		/**
		 * 需要读取的包长
		 */
		private var mNextMessageLength : int;
		/**
		 * 自增包序
		 */
		private var mOrder : int = 0;
		/**
		 * 包头长度
		 */
		private const HEAD_LENGTH : uint = 2;
		/**
		 * 加载成功后回调
		 */
		protected var mNotifyCompleteds : Vector.<Function>;
		/**
		 * 报错后回调
		 */
		protected var mNotifyIOErrors : Vector.<Function>;

		public function SSocket()
		{
			objectEncoding = ObjectEncoding.AMF3;
			endian = Endian.BIG_ENDIAN;
			mBytes = new ByteArray();
		}

		override public function connect(ip : String, port : int) : void
		{
			addListener();
			super.connect(ip, port);
		}

		/**
		 * 加载完成通知处理函数
		 * @param notifyFunction
		 * @return
		 *
		 */
		public function addNotifyCompleted(notifyFunction : Function) : void
		{
			if (!mNotifyCompleteds)
				mNotifyCompleteds = new Vector.<Function>();
			if (mNotifyCompleteds.indexOf(notifyFunction) == -1)
				mNotifyCompleteds.push(notifyFunction);
		}

		/**
		 * 加载错误通知处理函数
		 * @param notifyFunction
		 * @return
		 *
		 */
		public function addNotifyIOError(notifyFunction : Function) : void
		{
			if (!mNotifyIOErrors)
				mNotifyIOErrors = new Vector.<Function>();
			if (mNotifyIOErrors.indexOf(notifyFunction) == -1)
				mNotifyIOErrors.push(notifyFunction);
		}

		private function invokeNotifyByArray(functions : Vector.<Function>) : void
		{
			if (!functions)
				return;
			for each (var notify : Function in functions)
			{
				notify(this);
			}
			functions.length = 0;
		}

		/**
		 *身份验证
		 * @param data
		 *
		 */
		public function identity() : void
		{
			if (!connected)
			{
				return;
			}

			this.writeUTFBytes("ABCDEFGHIJKLMN876543210");
			this.flush();
		}

		/**
		 *	发送网络数据
		 * @param module	- 模块路由
		 * @param data		- 具体数据
		 *
		 */
		public function send(module : uint, dataBytes : SByteArray) : void
		{
			if (!connected)
			{
				return;
			}
			//取对象
			var sendBytes : SByteArray = SObjectManager.getObject(SByteArray);
			sendBytes.writeShort(dataBytes.length); // 写入包长(不包括包头长度)
			sendBytes.writeByte(mOrder);
			sendBytes.writeShort(module);
			sendBytes.writeBytes(dataBytes, 0, dataBytes.bytesAvailable);
			writeBytes(sendBytes);
			flush();

			if (mOrder >= 255)
				mOrder = 0;
			else
				mOrder++;
			//用完立马回收
			SObjectManager.recycleObject(sendBytes);
			SObjectManager.recycleObject(dataBytes);
		}

		private function addListener() : void
		{
			addEventListener(Event.CONNECT, onConnectHandler);
			addEventListener(Event.CLOSE, onCloseHandler);
			addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
			addEventListener(ProgressEvent.SOCKET_DATA, socketDataHandler);
		}

		private function removeListener() : void
		{
			removeEventListener(Event.CONNECT, onConnectHandler);
			removeEventListener(Event.CLOSE, onCloseHandler);
			removeEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			removeEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
			removeEventListener(ProgressEvent.SOCKET_DATA, socketDataHandler);
		}

		/**
		 * socket被关闭
		 * @param event
		 *
		 */
		protected function onCloseHandler(event : Event) : void
		{
			removeListener()
		}

		/**
		 * 连接成功
		 * @param event
		 *
		 */
		protected function onConnectHandler(event : Event) : void
		{
			invokeNotifyByArray(mNotifyCompleteds);
		}

		/**
		 * 连接错误
		 * @param event
		 *
		 */
		protected function ioErrorHandler(event : IOErrorEvent) : void
		{
			removeListener()
			invokeNotifyByArray(mNotifyIOErrors);
			try
			{
				close();
			}
			catch (e : Error)
			{
			}
		}

		/**
		 * 连接异常
		 * @param event
		 *
		 */
		protected function securityErrorHandler(event : SecurityErrorEvent) : void
		{
			removeListener()
			invokeNotifyByArray(mNotifyIOErrors);
			try
			{
				close();
			}
			catch (e : Error)
			{
			}
		}

		override public function close() : void
		{
			mOrder = 0;
			super.close();
		}


		/**
		 * 解包过程
		 * 处理半包和粘包
		 */
		private function socketDataHandler(event : ProgressEvent) : void
		{
			if (mNextMessageLength > 0 && bytesAvailable >= mNextMessageLength)
			{
				readMessage();
			}

			while (mNextMessageLength == 0 && bytesAvailable >= HEAD_LENGTH)
			{
				mNextMessageLength = readUnsignedShort();

				if (bytesAvailable >= mNextMessageLength)
				{
					readMessage();
				}
				else
				{
					mNextMessageLength = length;
					return;
				}
			}
		}

		private function readMessage() : void
		{
			mBytes.clear();
			readBytes(mBytes, 0, mNextMessageLength);
			mNextMessageLength = 0;
			parseBytes(mBytes.readUnsignedShort(), mBytes);
		}

		/**
		 * 解析包
		 * @param module
		 * @param pack
		 *
		 */
		protected function parseBytes(module : int, pack : ByteArray) : void
		{

		}
	}
}
