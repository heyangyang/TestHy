package hy.game.net
{
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;

	import hy.game.manager.SObjectManager;
	import hy.game.net.interfaces.INotify;
	import hy.game.utils.SDebug;

	/**
	 * 游戏唯一的一个套接字
	 * 负责游戏所有与服务器的实时通讯
	 * @author hyy
	 *
	 */
	public class SGameSocket extends SSocket
	{
		private static var _instance : SGameSocket;

		public static function getInstance() : SGameSocket
		{
			if (_instance == null)
				_instance = new SGameSocket();
			return _instance;
		}

		/**
		 * 协议id所对应的解析类
		 */
		protected var m_protocolId_dic : Dictionary;

		public function SGameSocket()
		{
			m_protocolId_dic = new Dictionary(true);
		}

		/**
		 * 添加一个网络监听模块
		 * @param module
		 * @param handler
		 *
		 */
		public function addHandler(protocolId : uint, handler : INotify) : void
		{
			if (m_protocolId_dic[protocolId])
			{
				SDebug.error("添加重复协议", protocolId)
			}
			m_protocolId_dic[protocolId] = handler;
		}

		/**
		 *移除指定的网络监听模块
		 * @param module
		 *
		 */
		public function removeHandler(protocolId : uint) : void
		{
			m_protocolId_dic[protocolId] = null;
			delete m_protocolId_dic[protocolId];
		}

		public function sendData(dataBase : SNetBaseData) : void
		{
			send(dataBase.cmdId, dataBase.serialize());
			SObjectManager.recycleObject(dataBase);
		}

		private var m_dataClass : Class
		private var m_dataBase : SNetBaseData;
		private var m_notify : INotify;

		override protected function parseBytes(module : int, pack : ByteArray) : void
		{
			m_dataClass = SCCommand.getClassByModule(module);

			if (m_dataClass == null)
			{
				SDebug.warning("module :", module, "not find data");
				return;
			}

			//取对象
			m_dataBase = SObjectManager.getObject(m_dataClass);
			m_dataBase.deSerialize(pack);
			m_notify = m_protocolId_dic[module];

			if (m_notify)
			{
				m_notify.handleMessage(module, m_dataBase);
			}
			else
			{
				SDebug.warning("module :", module, "not find notify");
			}
			//用完立马回收
			m_dataBase.destroy();
			SObjectManager.recycleObject(m_dataBase);
		}
	}
}