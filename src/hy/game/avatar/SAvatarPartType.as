package hy.game.avatar
{

	/**
	 *
	 * 一个纸娃娃部件类型枚举
	 *
	 */
	public final class SAvatarPartType
	{
		/**
		 * 完整部件
		 */
		public static const WHOLE_PART : uint = 1;
		/**
		 * 身体部件
		 */
		public static const BODY_PART : uint = 2;
		/**
		 * 武器部件
		 */
		public static const WEAPON_PART : uint = 3;
		/**
		 * 翅膀部件
		 */
		public static const WING_PART : uint = 4;

		public static const PART_TYPE_MAP : Array = [WHOLE_PART, BODY_PART, WEAPON_PART, WING_PART];
		public static const PART_NAME_MAP : Array = ["whole", "body", "weapon", "wing"];
		public static const PART_CHINESE_NAME_MAP : Array = ["全部", "身体", "武器", "翅膀"];

		public static function getPartTypeByName(name : String) : uint
		{
			var index : int = PART_NAME_MAP.indexOf(name.toLowerCase());
			if (index != -1)
				return PART_TYPE_MAP[index];
			return 0;
		}

		public static function getPartNameByType(type : uint) : String
		{
			var index : int = PART_TYPE_MAP.indexOf(type);
			if (index != -1)
				return PART_NAME_MAP[index];
			return null;
		}

		public static function getPartChineseNameByType(type : uint) : String
		{
			var index : int = PART_TYPE_MAP.indexOf(type);
			if (index != -1)
				return PART_CHINESE_NAME_MAP[index];
			return null;
		}

		public static function getPartChineseNameByName(name : String) : String
		{
			var action : uint = getPartTypeByName(name);
			return getPartChineseNameByType(action);
		}
	}
}