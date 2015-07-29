package hy.game.avatar
{


	/**
	 *
	 * 动作类型
	 *
	 */
	public final class SActionType
	{
		/**
		 * 空闲
		 */
		public static const IDLE : uint = 1;
		/**
		 * 奔跑
		 */
		public static const RUN : uint = 2;
		/**
		 * 跳跃
		 */
		public static const JUMP : uint = 3;
		/**
		 * 骑乘空闲
		 */
		public static const RIDE_IDLE : uint = 4;
		/**
		 * 骑乘行走
		 */
		public static const RIDE_WALK : uint = 5;
		/**
		 * 骑乘奔跑
		 */
		public static const RIDE_RUN : uint = 6;
		/**
		 * 坐下
		 */
		public static const SIT : uint = 7;
		/**
		 * 死亡
		 */
		public static const DIE : uint = 8;
		/**
		 * 起身
		 */
		public static const GET_UP : uint = 9;
		/**
		 * 击飞
		 */
		public static const LAUNCH : uint = 10;
		/**
		 * 跌落
		 */
		public static const LAND : uint = 11;
		/**
		 * 冲刺
		 */
		public static const DASH : uint = 12;

		/**
		 * 攻击
		 */
		public static const ATTACK : uint = 13;

		/**
		 * 行走
		 */
		public static const WALK : uint = 14;

		/**
		 * 受击
		 */
		public static const HIT : uint = 15; //BEEN_ATTACKE
		/**
		 * 备战
		 */
		public static const PREWAR : uint = 16;

		public static const ACTION_TYPE_MAP : Array = [IDLE, RUN, JUMP, RIDE_IDLE, RIDE_WALK, RIDE_RUN, SIT, DIE, GET_UP, LAUNCH, LAND, DASH, ATTACK, WALK, HIT, PREWAR];
		public static const ACTION_NAME_MAP : Array = ["idle", "run", "jump", "ride_idle", "ride_walk", "ride_run", "sit", "die", "getup", "launch", "land", "dash", "attack", "walk", "hit", "prewar"];
		public static const ACTION_CHINESE_NAME_MAP : Array = ["空闲", "奔跑", "跳跃", "骑乘空闲", "骑乘行走", "骑乘奔跑", "坐下", "死亡", "起身", "击飞", "跌落", "冲刺", "攻击", "行走", "受击", "备战"];

		public static function getActionTypeByName(name : String) : uint
		{
			var index : int = ACTION_NAME_MAP.indexOf(name.toLowerCase());
			if (index != -1)
				return ACTION_TYPE_MAP[index];
			return 0;
		}

		public static function getActionTypeByChineseName(name : String) : uint
		{
			var index : int = ACTION_CHINESE_NAME_MAP.indexOf(name.toLowerCase());
			if (index != -1)
				return ACTION_TYPE_MAP[index];
			return 0;
		}

		public static function getActionNameByType(type : uint) : String
		{
			var index : int = ACTION_TYPE_MAP.indexOf(type);
			if (index != -1)
				return ACTION_NAME_MAP[index];
			return null;
		}

		public static function getActionChineseNameByType(type : uint) : String
		{
			var index : int = ACTION_TYPE_MAP.indexOf(type);
			if (index != -1)
				return ACTION_CHINESE_NAME_MAP[index];
			return null;
		}

		public static function getActionChineseNameByName(name : String) : String
		{
			var action : uint = getActionTypeByName(name);
			return getActionChineseNameByType(action);
		}

		public static function getTypeAndKindByName(name : String) : Array
		{
			if (!name)
				return null;
			name = name.toLowerCase();
			var kind : uint;
			var index : int;
			for each (var actionName : String in ACTION_NAME_MAP)
			{
				if (name.indexOf(actionName) == 0)
				{
					kind = parseInt(name.substring(actionName.length));
					index = ACTION_NAME_MAP.indexOf(actionName);
					return [ACTION_TYPE_MAP[index], kind];
				}
			}
			return null;
		}
	}
}