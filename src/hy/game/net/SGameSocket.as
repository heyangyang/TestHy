package hy.game.net
{
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;

	import hy.game.manager.SMemeryManager;
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
		protected var mProtocolId_dic : Dictionary;

		public function SGameSocket()
		{
			mProtocolId_dic = new Dictionary(true);
		}

		/**
		 * 添加一个网络监听模块
		 * @param module
		 * @param handler
		 *
		 */
		public function addHandler(protocolId : uint, handler : INotify) : void
		{
			if (mProtocolId_dic[protocolId])
			{
				SDebug.error("添加重复协议", protocolId)
			}
			mProtocolId_dic[protocolId] = handler;
		}

		/**
		 *移除指定的网络监听模块
		 * @param module
		 *
		 */
		public function removeHandler(protocolId : uint) : void
		{
			mProtocolId_dic[protocolId] = null;
			delete mProtocolId_dic[protocolId];
		}

		public function sendData(dataBase : SNetBaseData) : void
		{
			send(dataBase.cmdId, dataBase.serialize());
			SMemeryManager.recycleObject(dataBase);
		}

		private var mDataClass : Class
		private var mDataBase : SNetBaseData;
		private var mNotify : INotify;

		override protected function parseBytes(module : int, pack : ByteArray) : void
		{
			mDataClass = SCCommand.getClassByModule(module);

			if (mDataClass == null)
			{
				SDebug.warning("module :", module, "not find data");
				return;
			}

			//取对象
			mDataBase = SMemeryManager.getObject(mDataClass);
			mDataBase.deSerialize(pack);
			mNotify = mProtocolId_dic[module];

			if (mNotify)
			{
				mNotify.handleMessage(module, mDataBase);
			}
			else
			{
				SDebug.warning("module :", module, "not find notify");
			}
			//用完立马回收
			mDataBase.dispose();
			SMemeryManager.recycleObject(mDataBase);
		}
	}
}