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
		private var m_animationsByPart : SAvatarAnimationLibrary;
		/**
		 * 当前avatar的描述
		 */
		private var m_avatarDesc : SAvatarDescription;
		// 当前动作
		private var m_curAction : uint;
		private var m_curKind : uint;

		public function SAvatar()
		{

		}

		public function initAvatar(desc : SAvatarDescription) : void
		{
			this.m_avatarDesc = desc;
			m_width = Math.abs(desc.rightBorder - desc.leftBorder);
			m_height = Math.abs(desc.bottomBorder - desc.topBorder);
		}

		/**
		 * 换方向
		 * @param dir [0-7]
		 * @return
		 */
		public function gotoDirection(dir : int) : SAnimationFrame
		{
			return gotoAnimation(m_curAction, m_curKind, dir, m_curFrameIndex, 0);
		}

		/**
		 * 播放 指定动画
		 * @param action  动作名称
		 * @param dir 方向
		 * @param index 跳到 Frame
		 * @return
		 *
		 */
		public function gotoAnimation(action : uint, kind : uint, dir : int, frame : int, loops : int) : SAnimationFrame
		{
			if (m_avatarDesc == null)
			{
				warning(this, "avatarDesc=null");
				return null;
			}
			if (action != 0)
			{
				if (hasAction(action, kind))
				{
					m_curAction = action;
					m_curKind = kind;
				}
				else
				{
					m_curAction = 0;
					m_curKind = 0;
					var avaliaAction : Array = getAvaliableAction(action);
					if (avaliaAction)
					{
						m_curAction = avaliaAction[0];
						m_curKind = avaliaAction[1];
					}
				}
			}

			if (!m_curAction)
			{
				return null;
			}

			m_curDir = dir;
			m_correctDir = EnumDirection.correctDirection(m_dirMode, m_correctDir, dir);

			if (m_correctDir != 0)
			{
				if (!hasDir(m_correctDir, m_curAction, m_curKind))
				{
					m_correctDir = getAvaliableDir(0, 0);
				}
			}
			m_curAnimation = m_animationsByPart.gotoAnimation(m_curAction, m_curKind, m_correctDir);
			m_loops = loops;
			gotoFrame(frame);
			return m_curAnimationFrame;
		}

		/**
		 * 是否有这个方向
		 * @param curDir
		 * @return
		 */
		public function hasDir(curDir : int, action : uint, kind : uint) : Boolean
		{
			if (action == 0)
			{
				action = m_curAction;
				kind = m_curKind;
			}
			if (m_avatarDesc == null || action == 0)
				return false;
			var actionDesc : SAvatarActionDescription = m_avatarDesc.getActionDescByAction(action, kind);
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
			if (m_avatarDesc == null)
				return false;
			if (m_avatarDesc.getActionDescByAction(action, kind))
				return true;
			return false;
		}

		/**
		 * 得到一个有效动作
		 * @return
		 */
		public function getAvaliableAction(action : int) : Array
		{
			if (m_avatarDesc && m_avatarDesc.getAvaliableActionByType(action))
				return m_avatarDesc.getAvaliableActionByType(action);
			else if (hasAction(SActionType.IDLE, 0))
				return [SActionType.IDLE, 0];
			else
				return m_avatarDesc.getAvaliableAction();
		}

		/**
		 * 得到一个可用的方向
		 * @return
		 */
		public function getAvaliableDir(action : uint, kind : uint) : int
		{
			if (!action)
			{
				action = m_curAction;
				kind = m_curKind;
			}
			var actionDesc : SAvatarActionDescription = m_avatarDesc.getActionDescByAction(action, kind);
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
			if (m_animationsByPart)
				m_animationsByPart.release();
			m_animationsByPart = value;
		}

		public function get animationsByParts() : SAvatarAnimationLibrary
		{
			return m_animationsByPart;
		}

		public function get curAction() : uint
		{
			return m_curAction;
		}

		public function get curKind() : uint
		{
			return m_curKind;
		}

		override public function dispose() : void
		{
			super.dispose();
			animationsByParts = null;
			m_avatarDesc = null;
		}
	}
}