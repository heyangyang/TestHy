package hy.game.avatar
{
	import flash.utils.Dictionary;

	import hy.rpg.enmu.SDirection;


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
		public var directions : Array = [SDirection.EAST];

		/**
		 * 由方向记录的动画id，即可以根据一个方向得到一个动画的id
		 */
		private var m_animationIdByDir : Dictionary;


		public function SAvatarPartDescription()
		{
			m_animationIdByDir = new Dictionary();
		}
		
		public function addAnimationIdByDir(dir : uint, id : String) : void
		{
			m_animationIdByDir[dir] = id;
		}
		
		public function getAnimationIdByDir(dir : uint) : String
		{
			var mode : uint = SDirection.checkDirsDirMode(directions);
			dir = SDirection.correctDirection(mode, dir, dir);
			return m_animationIdByDir[dir];
		}
		
		public function getAvaliableAnimation() : String
		{
			for each (var animationId : String in m_animationIdByDir)
			{
				if (animationId)
					return animationId;
			}
			return null;
		}
	}
}