package hy.game.avatar
{
	import flash.utils.Dictionary;

	import hy.game.manager.SBaseManager;
	import hy.game.animation.SAnimationManager;

	/**
	 *
	 * 纸娃娃管理器
	 *
	 */
	public class SAvatarManager extends SBaseManager
	{
		private static var instance : SAvatarManager;

		public static function getInstance() : SAvatarManager
		{
			if (!instance)
				instance = new SAvatarManager();
			return instance;
		}
		
		public function SAvatarManager()
		{
			if (instance)
				error("instance != null");
		}

		private var mAvatarDescByAvatarId : Dictionary = new Dictionary();

		public function addAvatarDescription(id : String, xml : XML, version : String = "0", isReplace : Boolean = false) : SAvatarDescription
		{
			if (mAvatarDescByAvatarId[id] == null || isReplace)
			{
				var avatarDesc : SAvatarDescription = parseAvatarDescription(xml, version);
				if (avatarDesc)
					mAvatarDescByAvatarId[id] = avatarDesc;
				return avatarDesc;
			}
			return getAvatarDescription(id);
		}

		/**
		 * 解析Parser 人物信息
		 * @param xml
		 * @return
		 *
		 */
		public function parseAvatarDescription(xml : XML, version : String = null) : SAvatarDescription
		{
			if (!xml)
				return null;

			var avatarDesc : SAvatarDescription = new SAvatarDescription();
			avatarDesc.name = String(xml.@name).toLowerCase();
			avatarDesc.version = String(xml.@version);
			avatarDesc.partOrder = [];

			var partOrder : Array = String(xml.@partOrder).split(',');
			for each (var partType : String in partOrder)
			{
				avatarDesc.partOrder.push(int(partType));
			}

			avatarDesc.width = int(xml.@width);
			avatarDesc.height = int(xml.@height);
			avatarDesc.leftBorder = int(xml.@leftBorder);
			avatarDesc.topBorder = int(xml.@topBorder);
			avatarDesc.rightBorder = int(xml.@rightBorder);
			avatarDesc.bottomBorder = int(xml.@bottomBorder);
			avatarDesc.setDirections(String(xml.@directions));

			var xmlList : XMLList = xml.action;
			var len : int = xmlList.length();
			var actionXML : XML;
			for (var i : int = 0; i < len; i++)
			{
				actionXML = xmlList[i];
				avatarDesc.addActionDesc(actionXML);
			}

			var animations : XML = <animations></animations>;
			var animationList : XMLList = xml.action.part.animation;
			animations.appendChild(animationList);
			//添加动画描述
			SAnimationManager.getInstance().addBatchAnimationDescription(animations, avatarDesc.width, avatarDesc.height, version);
			return avatarDesc;
		}

		public function getAvatarDescription(id : String) : SAvatarDescription
		{
			return mAvatarDescByAvatarId[id];
		}

	}
}