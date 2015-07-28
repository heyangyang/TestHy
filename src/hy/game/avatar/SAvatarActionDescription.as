package hy.game.avatar
{
	import flash.utils.Dictionary;

	/**
	 *
	 * 纸娃娃动作描述
	 *
	 */
	public class SAvatarActionDescription
	{
		public var name : String; //名称
		public var type : uint; //动作
		public var kind : uint; //种类
		/**
		 * 一个动画中开始作为正式攻击的时间
		 */
		public var attackTime : int;
		public var soundTime : int;

		/**
		 * 攻击起手帧
		 */
		public var attackStartFrame : int;
		public var attackStartDelay : int;
		/**
		 * 攻击收招帧
		 */
		public var attackEndFrame : int;
		public var attackEndDelay : int;
		/**
		 * 攻击判定帧
		 */
		public var attackHitFrame : int;

		/**
		 * 攻击移动帧
		 */
		public var attackMoveFrame : int;

		/**
		 * 攻击跳跃帧
		 */
		public var attackJumpFrame : int;

		/**
		 * 音效帧
		 */
		public var soundFrame : int;

		/**
		 * 动作拥有的方向
		 */
		public var directions : Array = [];

		public var jumpFrames : Array = [];
		public var sectionJumpFrames : Array = [];
		public var flightFrames : Array = [];
		public var jumpLandFrames : Array = [];

		/**
		 * 根据名字可以得到部件的描述
		 */
		public var partDescByName : Dictionary = new Dictionary();
		
		public function SAvatarActionDescription()
		{
			super();
		}

		public function getPartDescByName(partName : String) : SAvatarPartDescription
		{
			return partDescByName[partName];
		}

		/**
		 * 这个方法一般用于获得部件动画帧数，只需要获得一种就可以了，其他种类一定是一样的
		 * @return
		 *
		 */
		public function getAvaliablePart() : SAvatarPartDescription
		{
			for each (var desc : SAvatarPartDescription in partDescByName)
				return desc;
			return null;
		}

		public function setJumpFrames(frames : String) : void
		{
			if (!frames)
				jumpFrames = [];
			else
			{
				jumpFrames = frames.split(",");
				for (var i : int = jumpFrames.length - 1; i >= 0; i--)
				{
					jumpFrames[i] = int(jumpFrames[i]);
				}
			}
		}

		public function setFlightFrames(frames : String) : void
		{
			if (!frames)
				flightFrames = [];
			else
			{
				flightFrames = frames.split(",");
				for (var i : int = flightFrames.length - 1; i >= 0; i--)
				{
					flightFrames[i] = int(flightFrames[i]);
				}
			}
		}

		public function setJumpLandFrames(frames : String) : void
		{
			if (!frames)
				jumpLandFrames = [];
			else
			{
				jumpLandFrames = frames.split(",");
				for (var i : int = jumpLandFrames.length - 1; i >= 0; i--)
				{
					jumpLandFrames[i] = int(jumpLandFrames[i]);
				}
			}
		}

		public function setSectionJumpFrames(frames : String) : void
		{
			if (!frames)
				sectionJumpFrames = [];
			else
			{
				sectionJumpFrames = frames.split(",");
				for (var i : int = sectionJumpFrames.length - 1; i >= 0; i--)
				{
					sectionJumpFrames[i] = int(sectionJumpFrames[i]);
				}
			}
		}
	}
}