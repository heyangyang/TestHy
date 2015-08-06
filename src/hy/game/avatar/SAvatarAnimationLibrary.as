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
		private var m_animationByActionAndDir : Dictionary;
		/**
		 * 部件名称
		 */
		private var m_partName : String;

		public function SAvatarAnimationLibrary(priority : int, partName : String, avatarDesc : SAvatarDescription, needReversal : Boolean)
		{
			m_partName = partName;
			m_animationByActionAndDir = new Dictionary();
			createSinglePartAnimations(priority, avatarDesc, needReversal);
		}

		private function setAnimationByActionAndDir(action : uint, kind : uint, animationByDir : Dictionary) : void
		{
			m_animationByActionAndDir[action + "." + kind] = animationByDir;
		}

		private function getAnimationByActionAndDir(action : uint, kind : uint) : Dictionary
		{
			return m_animationByActionAndDir[action + "." + kind];
		}

		/**
		 * 拿出去的动画，记得要清理，否则不会销毁
		 * @param action
		 * @param kind
		 * @param dir
		 * @return
		 *
		 */
		public function gotoAnimation(action : uint, kind : uint, dir : int) : SAnimation
		{
			var dir2Animation : Dictionary = getAnimationByActionAndDir(action, kind);
			return dir2Animation[dir];
		}

		/**
		 * 加载所有的动画
		 *
		 */
		private var loader_count : int = 0;
		private var loader_index : int = 0;
		private var onReturnHanlder : Function;

		public function loaderAnimation(complete : Function = null) : void
		{
			var animation : SAnimationResource;
			var animationByDir : Dictionary;
			loader_count = loader_index = 0;
			onReturnHanlder = complete;
			for each (animationByDir in m_animationByActionAndDir)
			{
				for each (animation in animationByDir)
				{
					loader_count++;
					animation.constructFrames(1);
					animation.onLoaderComplete = onLoaderComplete;
					break;
				}
			}
		}

		private function onLoaderComplete() : void
		{
			if (++loader_index >= loader_count)
			{
				onReturnHanlder != null && onReturnHanlder();
				onReturnHanlder = null;
			}
		}

		/**
		 * 是否全部加载完毕
		 * @return
		 *
		 */
		public function get isLoaded() : Boolean
		{
			var animation : SAnimation;
			var animationByDir : Dictionary;
			for each (animationByDir in m_animationByActionAndDir)
			{
				for each (animation in animationByDir)
				{
					if (!animation.isLoaded)
						return false;
					break;
				}
			}
			return true;
		}

		override protected function destroy() : void
		{
			var animation : SAnimation;
			var animationByDir : Dictionary;
			for each (animationByDir in m_animationByActionAndDir)
			{
				for each (animation in animationByDir)
				{
					animation.destroy();
				}
			}
			onReturnHanlder = null;
			m_animationByActionAndDir = null;
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
		private function createSinglePartAnimations(priority : int, avatarDesc : SAvatarDescription, allNeedReversalPart : Boolean) : void
		{
			if (!m_partName || avatarDesc == null)
				return;

			var needReversalPart : Boolean;
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
				needReversalPart = allNeedReversalPart;
				animationByDir = new Dictionary();
				setAnimationByActionAndDir(actionDesc.type, actionDesc.kind, animationByDir);
				partDesc = actionDesc.partDescByName[m_partName];
				if (!partDesc)
					continue;
				dirs = actionDesc.directions; //当前有的方向数据
				if (needReversalPart)
					actionDesc.directions = dirs = EnumDirection.getReversalDirs(dirs);


				//构建该动作的方向动画			
				for each (dir in dirs)
				{
					needReversal = needReversalPart && EnumDirection.needMirrorReversal(dir);
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

		/**
		 * 根据一个部件描述和某些方向得到一堆动画描述（实际上是根据部件描述得到动画，方向位于同一文件内）
		 * @param partDesc
		 * @param dirs
		 * @param needReversalPart
		 * @return
		 *
		 */
		private function getAnimationDescByPartDescAndDirs(partDesc : SAvatarPartDescription, dirs : Array, needReversalPart : Boolean) : Array
		{
			var ids : Array = [];
			var dirNeedReversal : Boolean;
			var otherComposeingId : String;
			for each (var dir : int in dirs)
			{
				dirNeedReversal = needReversalPart && EnumDirection.needMirrorReversal(dir);
				if (dirNeedReversal)
				{ //如果需要反转
					dir = EnumDirection.getMirrorReversal(dir);
				}
				otherComposeingId = partDesc.getAnimationIdByDir(dir);

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