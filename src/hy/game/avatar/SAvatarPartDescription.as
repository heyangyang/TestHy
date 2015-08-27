package hy.game.avatar
{
	import flash.utils.Dictionary;

	import hy.rpg.enum.EnumDirection;


	/**
	 *
	 * 纸娃娃部件描述
	 *
	 */
	public class SAvatarPartDescription
	{
		/**
		 * 部件的类型，对应SAvatarPartType
		 */
		public var type : uint;
		public var kind : uint;

		/**
		 * 动画的id
		 */
		public var id : String;

		/**
		 * 动作拥有的方向
		 */
		public var directions : Array = [EnumDirection.EAST];

		/**
		 * 由方向记录的动画id，即可以根据一个方向得到一个动画的id
		 */
		private var mAnimationIdByDir : Dictionary;


		public function SAvatarPartDescription()
		{
			mAnimationIdByDir = new Dictionary();
		}
		
		public function addAnimationIdByDir(dir : uint, id : String) : void
		{
			mAnimationIdByDir[dir] = id;
		}
		
		public function getAnimationIdByDir(dir : uint) : String
		{
			var mode : uint = EnumDirection.checkDirsDirMode(directions);
			dir = EnumDirection.correctDirection(mode, dir, dir);
			return mAnimationIdByDir[dir];
		}
		
		public function getAvaliableAnimation() : String
		{
			for each (var animationId : String in mAnimationIdByDir)
			{
				if (animationId)
					return animationId;
			}
			return null;
		}
	}
}