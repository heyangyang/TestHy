package hy.game.manager
{
	import flash.utils.Dictionary;

	import hy.game.data.SVersion;

	/**
	 * 版本管理器
	 * @author hyy
	 *
	 */
	public class SVersionManager extends SBaseManager
	{
		private static var instance : SVersionManager;

		public static function getInstance() : SVersionManager
		{
			if (!instance)
				instance = new SVersionManager();
			return instance;
		}
		private var m_globalData : Dictionary;

		public function SVersionManager()
		{
			if (instance)
				error("instance != null");
			m_globalData = new Dictionary();
		}

		public function parseVersionData(data : String) : void
		{
			var list : Array = data.split("\n");
			var len : int = list.length;
			var tmpArr : Array;
			var version : SVersion;
			for (var i : int = 0; i < len; i++)
			{
				tmpArr = list[i].split("\t");
				version = new SVersion();
				version.id = tmpArr[0];
				version.url = tmpArr[1];
				version.version = tmpArr[3];
				version.type = tmpArr[4];
				m_globalData[version.id] = version;
			}
		}

		public function getVersionById(id : String) : SVersion
		{
			return m_globalData[id];
		}

	}
}