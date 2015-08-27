package hy.game.avatar
{
	import flash.utils.Dictionary;
	
	import hy.game.animation.SAnimation;
	import hy.game.animation.SAnimationManager;
	import hy.game.animation.SAnimationResource;
	import hy.game.core.SReference;
	import hy.rpg.enum.EnumDirection;



	/**
	 *
	 * 纸娃娃动画库，部件拥有的所有动画
	 * 二级字典，action映射到 dir2Animation, dir映射到Animation
	 * 通过动作名可以映射到8个方向的动画，在从其中取出某个方向的动画
	 *
	 */
	public class SAvatarAnimationLibrary extends SReference
	{
		private var mAnimationByActionAndDir : Dictionary;
		private var mAvatarDes : SAvatarDescription;
		private var mAvatarId : String;
		/**
		 * 加载所有的动画
		 */
		private var mLoaderCount : int = 0;
		private var mLoaderIndex : int = 0;
		private var mOnReturnHanlder : Function;

		public function SAvatarAnimationLibrary(priority : int, avatarId : String, avatarDesc : SAvatarDescription)
		{
			mAvatarId = avatarId;
			mAvatarDes = avatarDesc;
			mAnimationByActionAndDir = new Dictionary();
			createSinglePartAnimations(priority, avatarDesc);
		}

		private function setAnimationByActionAndDir(action : uint, animationByDir : Dictionary) : void
		{
			mAnimationByActionAndDir[action] = animationByDir;
		}

		private function getAnimationByActionAndDir(action : uint) : Dictionary
		{
			return mAnimationByActionAndDir[action];
		}

		/**
		 * 拿出去的动画，记得要清理，否则不会销毁
		 * @param action
		 * @param kind
		 * @param dir
		 * @return
		 *
		 */
		public function gotoAnimation(action : uint, dir : int) : SAnimation
		{
			var dir2Animation : Dictionary = getAnimationByActionAndDir(action);
			return dir2Animation[dir];
		}

		/**
		 * 加载所有动画
		 * @param complete
		 *
		 */
		public function loaderAnimation(complete : Function = null) : void
		{
			var animation : SAnimationResource;
			var animationByDir : Dictionary;
			mLoaderCount = mLoaderIndex = 0;
			mOnReturnHanlder = complete;
			for each (animationByDir in mAnimationByActionAndDir)
			{
				for each (animation in animationByDir)
				{
					mLoaderCount++;
					animation.constructFrames(1);
					animation.onLoaderComplete = onLoaderComplete;
					break;
				}
			}
		}

		private function onLoaderComplete() : void
		{
			if (++mLoaderIndex >= mLoaderCount)
			{
				mOnReturnHanlder != null && mOnReturnHanlder();
				mOnReturnHanlder = null;
			}
		}

		/**
		 * 是否全部加载完毕
		 * @return
		 *
		 */
		public function get isLoaded() : Boolean
		{
			return mLoaderIndex >= mLoaderCount;
		}

		override protected function destroy() : void
		{
			var animation : SAnimation;
			var animationByDir : Dictionary;
			for each (animationByDir in mAnimationByActionAndDir)
			{
				for each (animation in animationByDir)
				{
					animation.destroy();
				}
			}
			mOnReturnHanlder = null;
			mAnimationByActionAndDir = null;
			super.destroy();
		}

		/**
		 * 创建单个部件动画库
		 * @param avatarDesc
		 * @param priority
		 * @param allNeedReversalPart
		 * @return
		 *
		 */
		private function createSinglePartAnimations(priority : int, avatarDesc : SAvatarDescription) : void
		{
			if (!mAvatarId || avatarDesc == null)
				return;

			var animationByDir : Dictionary;
			var partDesc : SAvatarPartDescription;
			var dirs : Array;
			var animationId : String;
			var id : String;
			var needReversal : Boolean;
			var revrsalDir : int;
			var dir : int;
			var animation : SAnimationResource;
			//构建每个动作的8方向动画
			for each (var actionDesc : SAvatarActionDescription in avatarDesc.actionDescByActionMap)
			{
				animationByDir = new Dictionary();
				setAnimationByActionAndDir(actionDesc.type, animationByDir);
				partDesc = actionDesc.partDescByName[mAvatarId];
				if (!partDesc)
					continue;
				dirs = actionDesc.directions; //当前有的方向数据
				//翻转所有动画
				actionDesc.directions = dirs = EnumDirection.getReversalDirs(dirs);

				//构建该动作的方向动画			
				for each (dir in dirs)
				{
					needReversal = EnumDirection.needMirrorReversal(dir);
					if (needReversal)
					{
						revrsalDir = EnumDirection.getMirrorReversal(dir);
						animationId = partDesc.getAnimationIdByDir(revrsalDir);
						if (animationId)
							id = animationId.substr(0, animationId.length - 1) + dir;
					}
					else
					{
						animationId = partDesc.getAnimationIdByDir(dir);
						id = animationId;
					}
					if (animationId && id)
					{
						animation = SAnimationManager.getInstance().createAnimation(id, animationId, needReversal) as SAnimationResource;
						animation.priority = priority;
						if (animation)
							animationByDir[dir] = animation;
						else
							warning(this, "创建纸娃娃动画" + id + "对应的动画" + animationId + "失败！");
					}
					else
						warning(this, "创建纸娃娃动画" + id + "对应的方向" + dir + "失败！");
				}
			}
		}

		public function get avatarDes() : SAvatarDescription
		{
			return mAvatarDes;
		}
	}
}