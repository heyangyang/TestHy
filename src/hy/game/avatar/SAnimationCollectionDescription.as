package hy.game.avatar
{
	import flash.utils.Dictionary;
	
	import hy.rpg.enmu.SDirection;

	/**
	 *
	 * 动画集合描述
	 *
	 */
	public class SAnimationCollectionDescription
	{
		/**
		 * 动画的id
		 */
		public var id : String;

		public function SAnimationCollectionDescription()
		{
			_animationIdByDir = new Dictionary();
		}

		/**
		 * 动作拥有的方向
		 */
		public var directions : Array = [SDirection.EAST];

		/**
		 * 由方向记录的动画id，即可以根据一个方向得到一个动画的id
		 */
		private var _animationIdByDir : Dictionary;

		public function addAnimationIdByDir(dir : uint, id : String) : void
		{
			_animationIdByDir[dir] = id;
		}

		public function getAnimationIdByDir(dir : uint) : String
		{
			var mode : uint = SDirection.checkDirsDirMode(directions);
			dir = SDirection.correctDirection(mode, dir, dir);
			return _animationIdByDir[dir];
		}

		public function getAvaliableAnimation() : String
		{
			for each (var animationId : String in _animationIdByDir)
			{
				if (animationId)
					return animationId;
			}
			return null;
		}
	}
}