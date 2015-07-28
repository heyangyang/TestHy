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
		 * 无动作
		 */
		public static const NONE : uint = 0;
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

		public static const ACTION_TYPE_MAP : Array = [IDLE, RUN, JUMP, RIDE_IDLE, RIDE_WALK, //
			RIDE_RUN, SIT, DIE, GET_UP, LAUNCH, //
			LAND, DASH, ATTACK, WALK, HIT, PREWAR //
			/*,//
			   ATTACK1,ATTACK2,ATTACK3,ATTACK4,ATTACK5,ATTACK6,ATTACK7,ATTACK8,ATTACK9,ATTACK10,//
			   ATTACK11,ATTACK12,ATTACK13,ATTACK14,ATTACK15,ATTACK16,ATTACK17,ATTACK18,ATTACK19,ATTACK20,//
			 HIT1,HIT2*/];
		public static const ACTION_NAME_MAP : Array = ["idle", "run", "jump", "ride_idle", "ride_walk", //
			"ride_run", "sit", "die", "getup", "launch", //
			"land", "dash", "attack", "walk", "hit", "prewar" /*,//
			   //
			   "attack1","attack2","attack3","attack4","attack5","attack6","attack7","attack8","attack9","attack10",//
			   "attack11","attack12","attack13","attack14","attack15","attack16","attack17","attack18","attack19","attack20",//
			 "hit1","hit2"*/];
		public static const ACTION_CHINESE_NAME_MAP : Array = ["空闲", "奔跑", "跳跃", "骑乘空闲", "骑乘行走", //
			"骑乘奔跑", "坐下", "死亡", "起身", "击飞", //
			"跌落", "冲刺", "攻击", "行走", "受击", "备战" /*,//
			   //
			   "攻击一","攻击二","攻击三","攻击四","攻击五","攻击六","攻击七","攻击八","攻击九","攻击十",//
			   "攻击十一","攻击十二","攻击十三","攻击十四","攻击十五","攻击十六","攻击十七","攻击十八","攻击十九","攻击二十",
			 "受击一","受击二"*/];

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
			for each (var actionName : String in ACTION_NAME_MAP)
			{
				if (name.indexOf(actionName) == 0)
				{
					var kind : uint = parseInt(name.substring(actionName.length));
					var index : int = ACTION_NAME_MAP.indexOf(actionName);
					return [ACTION_TYPE_MAP[index], kind];
				}
			}
			return null;
		}
	}
}