package hy.game.avatar
{
	import hy.game.aEffect.SEffect;
	import hy.game.animation.SAnimationFrame;
	import hy.rpg.enum.EnumDirection;

	/**
	 * 纸娃娃
	 *
	 */
	public class SAvatar extends SEffect
	{
		/**
		 * 所有部件对应的各自动画
		 */
		private var mAnimationsByPart : SAvatarAnimationLibrary;
		/**
		 * 当前avatar的描述
		 */
		private var mAvatarDesc : SAvatarDescription;
		// 当前动作
		private var mCurAction : uint;

		public function SAvatar()
		{

		}

		private function initAvatar(desc : SAvatarDescription) : void
		{
			mAvatarDesc = desc;
			mWidth = Math.abs(desc.rightBorder - desc.leftBorder);
			mHeight = Math.abs(desc.bottomBorder - desc.topBorder);
		}

		/**
		 * 换方向
		 * @param dir [0-7]
		 * @return
		 */
		public function gotoDirection(dir : int) : SAnimationFrame
		{
			return gotoAnimation(mCurAction, dir, mCurFrameIndex, 0);
		}

		/**
		 * 播放 指定动画
		 * @param action  动作名称
		 * @param dir 方向
		 * @param index 跳到 Frame
		 * @return
		 *
		 */
		public function gotoAnimation(action : uint, dir : int, frame : int, loops : int) : SAnimationFrame
		{
			if (!mAvatarDesc)
				return null;
			if (action != 0)
			{
				if (hasAction(action, 0))
				{
					mCurAction = action;
				}
				else
				{
					warning(mAvatarDesc.name, "not find action : ", action);
					mCurAction = 0;
					var avaliaAction : Array = getAvaliableAction(action);
					if (avaliaAction)
					{
						mCurAction = avaliaAction[0];
					}
				}
			}

			if (!mCurAction)
				return null;

			mCurDir = dir;
			//矫正方向
			mCorrectDir = EnumDirection.correctDirection(mDirMode, mCorrectDir, dir);

			if (mCorrectDir != 0)
			{
				if (!hasDir(mCorrectDir, mCurAction))
				{
					mCorrectDir = getAvaliableDir(0, 0);
					warning(mAvatarDesc.name, "not find dir : ", dir);
				}
			}
			mCurAnimation = mAnimationsByPart.gotoAnimation(mCurAction, mCorrectDir);
			mLoops = loops;
			gotoFrame(frame);
			return mCurAnimationFrame;
		}

		/**
		 * 是否有这个方向
		 * @param curDir
		 * @return
		 */
		public function hasDir(curDir : int, action : uint) : Boolean
		{
			if (mAvatarDesc == null || action == 0)
				return false;
			var actionDesc : SAvatarActionDescription = mAvatarDesc.getActionDescByAction(action, 0);
			if (actionDesc)
			{
				var dirs : Array = actionDesc.directions;
				for each (var dir : int in dirs)
				{
					if (dir == curDir)
						return true;
				}
			}
			return false;
		}

		/**
		 * 根据描述确定是否有该动作
		 * @param action
		 * @return
		 */
		public function hasAction(action : uint, kind : uint) : Boolean
		{
			if (mAvatarDesc == null)
				return false;
			if (mAvatarDesc.getActionDescByAction(action, kind))
				return true;
			return false;
		}

		/**
		 * 得到一个有效动作
		 * @return
		 */
		public function getAvaliableAction(action : int) : Array
		{
			if (mAvatarDesc && mAvatarDesc.getAvaliableActionByType(action))
				return mAvatarDesc.getAvaliableActionByType(action);
			else if (hasAction(SActionType.IDLE, 0))
				return [SActionType.IDLE, 0];
			else
				return mAvatarDesc.getAvaliableAction();
		}

		/**
		 * 得到一个可用的方向
		 * @return
		 */
		public function getAvaliableDir(action : uint, kind : uint) : int
		{
			if (!action)
				action = mCurAction;
			var actionDesc : SAvatarActionDescription = mAvatarDesc.getActionDescByAction(action, kind);
			if (actionDesc)
			{
				var dirs : Array = actionDesc.directions;
				if (dirs.length > 0)
					return int(dirs[0]);
			}
			return 0;
		}

		/**
		 * 设置当前动画库
		 * @param value
		 *
		 */
		public function set animationsByParts(value : SAvatarAnimationLibrary) : void
		{
			if (mAnimationsByPart)
				mAnimationsByPart.release();
			mAnimationsByPart = value;
			if (mAnimationsByPart)
				initAvatar(mAnimationsByPart.avatarDes);
		}

		public function get animationsByParts() : SAvatarAnimationLibrary
		{
			return mAnimationsByPart;
		}

		public function get curAction() : uint
		{
			return mCurAction;
		}

		override public function dispose() : void
		{
			super.dispose();
			animationsByParts = null;
			mAvatarDesc = null;
		}
	}
}