package hy.game.avatar
{
	import hy.game.animation.SAnimation;
	import hy.game.animation.SAnimationFrame;
	import hy.game.data.SObject;
	import hy.rpg.enum.EnumDirection;

	/**
	 * 纸娃娃
	 *
	 */
	public class SAvatar extends SObject
	{
		/**
		 * 所有部件对应的各自动画
		 */
		private var m_animationsByPart : SAvatarAnimationLibrary;
		/**
		 * 当前avatar的描述
		 */
		public var m_avatarDesc : SAvatarDescription;
		private var m_width : int;
		private var m_height : int;
		//当前动画
		private var m_curAnimation : SAnimation;
		private var m_curAnimationFrame : SAnimationFrame;
		// 当前动作
		private var m_curAction : uint = SActionType.IDLE;
		private var m_curKind : uint = 0;
		//当前方向
		private var m_curDir : uint = EnumDirection.EAST;
		private var m_correctDir : uint = EnumDirection.EAST;
		private var m_dirMode : uint = EnumDirection.DIR_MODE_HOR_ONE;
		/**
		 * 当前帧逝去时间
		 */
		protected var m_curFrameElapsedTime : int;
		/**
		 * 当前帧持续的时间
		 */
		protected var m_curFrameDuration : int;
		/**
		 * 当前的动画帧索引
		 */
		protected var m_curFrameIndex : int;
		/**
		 * 是否暂停播放
		 */
		protected var m_isPaused : Boolean;

		/**
		 * 当前帧是否到最后一帧
		 */
		protected var m_isEnd : Boolean;
		/**
		 *  是否播放次数结束
		 */
		protected var m_isLoopEnd : Boolean;
		/**
		 * 刚开始播放
		 */
		protected var m_isJustStarted : Boolean;
		/**
		 * 动画总共需要循环的次数
		 */
		protected var m_loops : int = 0;
		/**
		 * 当前已经循环的次数
		 */
		protected var m_curLoop : int;

		private var m_skipFrames : int
		private var m_nextFrame : SAnimationFrame;

		public function SAvatar(desc : SAvatarDescription)
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
			return gotoAnimation(m_curAction, m_curKind, dir, curFrame, 0);
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

		public function gotoNextFrame(elapsedTime : int) : SAnimationFrame
		{
			if (!m_curAnimation)
				return null;
			if (!m_curAnimationFrame)
				return gotoFrame(1);
			if (m_isPaused)
				return m_curAnimationFrame;

			m_isJustStarted = false;
			m_curFrameDuration = m_curAnimationFrame.duration;
			m_curFrameElapsedTime += elapsedTime;

			if (m_curFrameElapsedTime < m_curFrameDuration)
				return m_curAnimationFrame;
			//要强制跳的帧数
			m_skipFrames = m_curFrameElapsedTime / m_curFrameDuration;
			//大于一帧的跳帧情况
			if (m_skipFrames > 1)
			{
				do
				{
					m_curFrameElapsedTime -= m_curFrameDuration;
					m_curFrameIndex += 1;
					if (m_curFrameIndex >= totalFrame)
					{
						m_curFrameIndex = totalFrame;
						break;
					}
					else
					{
						m_nextFrame = getFrame(m_curFrameIndex + 1);
						m_curFrameDuration = m_nextFrame.duration;
					}
				} while (m_curFrameElapsedTime >= m_curFrameDuration)
			}
			else
			{
				//求余值 
				m_curFrameElapsedTime = m_curFrameElapsedTime % m_curFrameDuration;
				m_curFrameIndex += m_skipFrames;
			}

			//如果播放到动画尾，重新从第一帧开始播放
			if (m_curFrameIndex >= totalFrame)
			{
				m_curLoop++;
				//从0帧开始跳转 当前帧索引 相对于 总帧数 的余数
				m_curFrameIndex = m_curFrameIndex % totalFrame;
				//如果需要记录结束 ，则不跳转
				if (m_loops > 0 && m_curLoop >= m_loops)
				{
					gotoFrame(totalFrame);
					m_isLoopEnd = true;
				}
				else
				{
					m_isJustStarted = true;
					gotoFrame(m_curFrameIndex + 1);
				}
			}
			else
			{
				gotoFrame(m_curFrameIndex + 1);
			}

			if (m_curFrameIndex >= totalFrame && m_curFrameElapsedTime >= m_curFrameDuration)
				m_isEnd = true;
			return m_curAnimationFrame;
		}

		public function gotoFrame(frame : int) : SAnimationFrame
		{
			if (!m_curAnimation)
				return null;
			if (frame < 1)
				frame = 1;
			if (frame > totalFrame)
				frame = totalFrame;
			m_curFrameElapsedTime = 0;
			m_curFrameIndex = frame - 1;

			m_curAnimation.constructFrames(frame);
			m_curAnimationFrame = m_curAnimation.getFrame(m_curFrameIndex);
			while (m_curAnimationFrame && m_curAnimationFrame.duration <= 0)
			{
				frame++;
				m_curFrameIndex = frame - 1;
				if (m_curFrameIndex >= 0 && m_curFrameIndex < totalFrame)
				{
					m_curAnimation.constructFrames(frame);
					m_curAnimationFrame = m_curAnimation.getFrame(m_curFrameIndex);
				}
				else
				{
					frame = totalFrame;
					m_curFrameIndex = frame - 1;
					m_curAnimation.constructFrames(frame);
					m_curAnimationFrame = m_curAnimation.getFrame(m_curFrameIndex);
					break;
				}
			}
			m_isEnd = frame >= totalFrame;
			return m_curAnimationFrame;
		}

		// 暂定播放动画
		public function pause() : void
		{
			m_isPaused = true;
		}

		// 恢复播放动画
		public function resume(elapsedTime : int = 0) : void
		{
			m_isPaused = false;
			m_curFrameElapsedTime = 0;
			m_isEnd = false;
			m_isLoopEnd = false;
			m_isJustStarted = true;
			m_curLoop = 0;
		}

		public function get isEnd() : Boolean
		{
			if (!m_curAnimation)
				return false;
			return m_isEnd && m_isLoopEnd;
		}

		public function get isLoopEnd() : Boolean
		{
			return m_curAnimation ? m_isLoopEnd : false;
		}

		public function get curFrameIndex() : int
		{
			return m_curAnimation ? m_curFrameIndex : 0;
		}

		public function get curFrame() : int
		{
			return m_curAnimation ? m_curFrameIndex + 1 : 1;
		}

		public function get totalFrame() : int
		{
			return m_curAnimation ? m_curAnimation.totalFrame : 1;
		}

		public function get isJustStarted() : Boolean
		{
			return m_curAnimation ? m_isJustStarted : true;
		}

		public function get isPaused() : Boolean
		{
			return m_curAnimation ? m_isPaused : true;
		}

		public function get curAnimationFrame() : SAnimationFrame
		{
			return m_curAnimation ? m_curAnimationFrame : null;
		}

		public function getFrame(frame : int) : SAnimationFrame
		{
			return m_curAnimation ? m_curAnimation.getFrame(frame - 1) : null;
		}

		public function get loops() : int
		{
			return m_loops;
		}

		public function set loops(value : int) : void
		{
			m_loops = value;
		}

		public function getFrameDurations(frame : int = 1) : int
		{
			return m_curAnimation ? m_curAnimation.getFrameDurations(frame) : 0;
		}

		public function get curDir() : int
		{
			return m_curDir;
		}

		public function get curAction() : uint
		{
			return m_curAction;
		}

		public function get curKind() : uint
		{
			return m_curKind;
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
			var actionDesc : SAvatarActionDescription = m_avatarDesc.getActionDescByAction(action, kind);
			if (actionDesc)
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

		public function get width() : int
		{
			return m_width;
		}

		public function set width(value : int) : void
		{
			if (m_width != value)
				m_width = value;
		}

		public function get height() : int
		{
			return m_height;
		}

		public function set height(value : int) : void
		{
			if (m_height != value)
				m_height = value;
		}

		public function get animation_width() : int
		{
			return m_curAnimation ? m_curAnimation.width : 0;
		}

		public function get animation_height() : int
		{
			return m_curAnimation ? m_curAnimation.height : 0;
		}

		public function get offsetX() : int
		{
			return m_curAnimation ? m_curAnimation.offsetX : 0;
		}

		public function get offsetY() : int
		{
			return m_curAnimation ? m_curAnimation.offsetY : 0;
		}

		public function get hasAnimation() : Boolean
		{
			return m_curAnimation != null;
		}

		public function get correctDir() : uint
		{
			return m_correctDir;
		}

		public function set dirMode(value : uint) : void
		{
			m_dirMode = value;
		}

		public function get dirMode() : uint
		{
			return m_dirMode;
		}

		public function dispose() : void
		{
			animationsByParts = null;
			m_avatarDesc = null;
			m_curAnimation = null;
			m_curAnimationFrame = null;
		}
	}
}