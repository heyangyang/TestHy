package hy.game.aEffect
{
	import flash.utils.Dictionary;

	import hy.game.core.SReference;
	import hy.game.utils.SDebug;
	import hy.rpg.enum.EnumDirection;
	import hy.game.animation.SAnimation;
	import hy.game.animation.SAnimationManager;


	/**
	 *
	 * 动画库，方向拥有的所有动画
	 * 一级字典，dir映射到Animation
	 * 通过方向可以映射到8个方向的动画，在从其中取出某个方向的动画
	 *
	 */
	public class SEffectAnimationLibrary extends SReference
	{
		private var _animationByDir : Dictionary;
		/**
		 * 当前effect的描述
		 */
		private var effectDesc : SEffectDescription;
		private var _width : int;
		private var _height : int;
		private var _dirMode : uint = EnumDirection.DIR_MODE_HOR_ONE;

		public function SEffectAnimationLibrary(desc : SEffectDescription, needReversal : Boolean)
		{
			_animationByDir = new Dictionary();
			if (desc.version == "2")
				_dirMode = EnumDirection.checkDirsDirMode(desc.directions);
			this.effectDesc = desc;
			_width = Math.abs(desc.rightBorder - desc.leftBorder);
			_height = Math.abs(desc.bottomBorder - desc.topBorder);
			createAnimations(desc, needReversal);
		}

		public function gotoAnimation(dir : int) : SAnimation
		{
			if (effectDesc == null)
				return null;

			var cur_dir : int = EnumDirection.correctDirection(_dirMode, EnumDirection.EAST, dir); //对方向进行修正

			if (cur_dir != 0 && !hasDir(cur_dir))
			{
				cur_dir = getAvaliableDir();
				SDebug.warning(this, effectDesc.id + "配置文件不存在方向" + dir + "的资源，将取有效方向：" + cur_dir);
			}

			return _animationByDir[cur_dir];
		}

		/**
		 * 是否有这个方向
		 * @param curDir
		 * @return
		 */
		public function hasDir(curDir : int) : Boolean
		{
			if (effectDesc == null)
				return false;
			var dirs : Array = effectDesc.animationDirections;
			for each (var dir : int in dirs)
			{
				if (dir == curDir)
					return true;
			}
			return false;
		}

		/**
		 * 得到一个可用的方向
		 * @return
		 */
		public function getAvaliableDir() : int
		{
			if (effectDesc)
			{
				var dirs : Array = effectDesc.animationDirections;
				if (dirs.length > 0)
					return int(dirs[0]);
			}
			return 0;
		}

		public function get dirMode() : uint
		{
			return _dirMode;
		}

		public function get width() : int
		{
			return _width;
		}

		public function get height() : int
		{
			return _height;
		}

		override protected function destroy() : void
		{
			for each (var animation : SAnimation in _animationByDir)
			{
				animation.destroy();
			}
			_animationByDir = null;
			super.destroy();
		}

		/**
		 * 创建动画库
		 * @param effectDesc
		 * @param priority
		 * @param needReversal
		 * @return
		 *
		 */
		private function createAnimations(effectDesc : SEffectDescription, needReversal : Boolean) : SEffectAnimationLibrary
		{
			if (effectDesc == null)
				return null;

			var dirs : Array = effectDesc.directions; //当前有的方向数据
			if (needReversal)
				effectDesc.animationDirections = dirs = EnumDirection.getReversalDirs(dirs);
			else
				effectDesc.animationDirections = dirs;

			//构建每个方向动作的8方向动画
			var isReversal : Boolean;
			var animationId : String;
			var id : String;
			for each (var dir : int in dirs)
			{
				isReversal = needReversal && EnumDirection.needMirrorReversal(dir);
				animationId = id = effectDesc.getAnimationIdByDir(dir);
				if (isReversal)
				{
					var revrsalDir : int = EnumDirection.getMirrorReversal(dir);
					animationId = effectDesc.getAnimationIdByDir(revrsalDir);
					id = animationId.substr(0, animationId.length - 1) + dir;
				}
				_animationByDir[dir] = SAnimationManager.getInstance().createAnimation(id, animationId, isReversal);
			}
			return this;
		}

		/**
		 * 根据一个方向得到一堆动画描述（实际上是根据部件描述得到动画，方向位于同一文件内）
		 * @param partDesc
		 * @param dirs
		 * @param needReversalPart
		 * @return
		 *
		 */
		private function getAnimationDescByDirs(effectDesc : SEffectDescription, dirs : Array, needReversal : Boolean) : Array
		{
			var ids : Array = [];
			for each (var dir : int in dirs)
			{
				var dirNeedReversal : Boolean = needReversal && EnumDirection.needMirrorReversal(dir);
				if (dirNeedReversal)
				{ //如果需要反转
					dir = EnumDirection.getMirrorReversal(dir);
				}
				var otherComposeingId : String = effectDesc.getAnimationIdByDir(dir);

				if (ids.indexOf(otherComposeingId) == -1)
					ids.push(otherComposeingId);
			}
			var descs : Array = [];
			if (ids != null)
			{
				for each (var id : String in ids)
				{
					descs.push(SAnimationManager.getInstance().getAnimationDescription(id));
				}
			}
			return descs;
		}
	}
}