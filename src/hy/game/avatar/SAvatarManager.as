package hy.game.avatar
{
	import flash.utils.Dictionary;
	
	import hy.game.manager.SBaseManager;

	/**
	 *
	 * 纸娃娃管理器
	 *
	 */
	public class SAvatarManager extends SBaseManager
	{
		private var _avatarDescByAvatarId : Dictionary = new Dictionary();

		private static var _instance : SAvatarManager;
		private var _parser : SAvatarParser = new SAvatarParser();

		public static function getInstance() : SAvatarManager
		{
			if (!_instance)
			{
				_instance = new SAvatarManager();
			}
			return _instance;
		}

		public function addAvatarDescription(id : String, xml : XML, version : String = "0", isReplace : Boolean = false) : SAvatarDescription
		{
			if (_avatarDescByAvatarId[id] == null || isReplace)
			{
				var avatarDesc : SAvatarDescription = _parser.parseAvatarDescription(xml, version);
				if (avatarDesc)
					_avatarDescByAvatarId[id] = avatarDesc;
				return avatarDesc;
			}
			return getAvatarDescription(id);
		}

		public function getAvatarDescription(id : String) : SAvatarDescription
		{
			return _avatarDescByAvatarId[id];
		}

		public function removeAvatarDescription(id : String) : void
		{
			if (_avatarDescByAvatarId[id])
			{
				_avatarDescByAvatarId[id] = null;
				delete _avatarDescByAvatarId[id];
			}
		}
	}
}