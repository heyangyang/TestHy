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
		private var m_bytes : ByteArray;
		/**
		 * 需要读取的包长
		 */
		private var nextMessageLength : int;
		/**
		 * 自增包序
		 */
		private var order : int = 0;
		/**
		 * 包头长度
		 */
		private const HEAD_LENGTH : uint = 2;
		/**
		 * 加载成功后回调
		 */
		protected var m_notifyCompleteds : Vector.<Function>;
		/**
		 * 报错后回调
		 */
		protected var m_notifyIOErrors : Vector.<Function>;

		public function SSocket()
		{
			objectEncoding = ObjectEncoding.AMF3;
			endian = Endian.BIG_ENDIAN;
			m_bytes = new ByteArray();
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
			if (!m_notifyCompleteds)
				m_notifyCompleteds = new Vector.<Function>();
			if (m_notifyCompleteds.indexOf(notifyFunction) == -1)
				m_notifyCompleteds.push(notifyFunction);
		}

		/**
		 * 加载错误通知处理函数
		 * @param notifyFunction
		 * @return
		 *
		 */
		public function addNotifyIOError(notifyFunction : Function) : void
		{
			if (!m_notifyIOErrors)
				m_notifyIOErrors = new Vector.<Function>();
			if (m_notifyIOErrors.indexOf(notifyFunction) == -1)
				m_notifyIOErrors.push(notifyFunction);
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
			sendBytes.writeByte(order);
			sendBytes.writeShort(module);
			sendBytes.writeBytes(dataBytes, 0, dataBytes.bytesAvailable);
			writeBytes(sendBytes);
			flush();

			if (order >= 255)
				order = 0;
			else
				order++;
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
			invokeNotifyByArray(m_notifyCompleteds);
		}

		/**
		 * 连接错误
		 * @param event
		 *
		 */
		protected function ioErrorHandler(event : IOErrorEvent) : void
		{
			removeListener()
			invokeNotifyByArray(m_notifyIOErrors);
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
			invokeNotifyByArray(m_notifyIOErrors);
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
			order = 0;
			super.close();
		}


		/**
		 * 解包过程
		 * 处理半包和粘包
		 */
		private function socketDataHandler(event : ProgressEvent) : void
		{
			if (nextMessageLength > 0 && bytesAvailable >= nextMessageLength)
			{
				readMessage();
			}

			while (nextMessageLength == 0 && bytesAvailable >= HEAD_LENGTH)
			{
				nextMessageLength = readUnsignedShort();

				if (bytesAvailable >= nextMessageLength)
				{
					readMessage();
				}
				else
				{
					nextMessageLength = length;
					return;
				}
			}
		}

		private function readMessage() : void
		{
			m_bytes.clear();
			readBytes(m_bytes, 0, nextMessageLength);
			nextMessageLength = 0;
			parseBytes(m_bytes.readUnsignedShort(), m_bytes);
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
