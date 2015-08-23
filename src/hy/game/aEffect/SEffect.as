package hy.game.aEffect
{
	import hy.game.animation.SAnimation;
	import hy.game.animation.SAnimationFrame;
	import hy.game.data.SObject;
	import hy.rpg.enum.EnumDirection;

	/**
	 * 特效
	 * @author hyy
	 *
	 */
	public class SEffect extends SObject
	{
		/**
		 * 所有部件对应的各自动画
		 */
		private var m_animationsByPart : SEffectAnimationLibrary;

		/**
		 * 当前avatar的描述
		 */
		private var m_effectDesc : SEffectDescription;
		/**
		 * 宽
		 */
		protected var m_width : int;
		/**
		 * 高
		 */
		protected var m_height : int;
		/**
		 * 当前动画
		 */
		protected var m_curAnimation : SAnimation;
		/**
		 * 当前动画帧
		 */
		protected var m_curAnimationFrame : SAnimationFrame;
		/**
		 * 方向
		 */
		protected var m_curDir : uint;
		protected var m_correctDir : uint;
		protected var m_dirMode : uint;
		/**
		 * 当前帧逝去时间
		 */
		protected var m_curFrameElapsedTime : int;
		/**
		 * 当前帧持续的时间
		 */
		protected var m_curFrameDuration : int;
		/**
		 * 当前的动画帧索引,从0开始
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
		protected var m_loops : int;
		/**
		 * 当前已经循环的次数
		 */
		protected var m_curLoop : int;
		/**
		 * 跳帧
		 */
		protected var m_skipFrames : int
		/**
		 * 下一帧
		 */
		protected var m_nextFrame : SAnimationFrame;

		public function SEffect()
		{

		}

		public function initEffect(desc : SEffectDescription) : void
		{
			m_effectDesc = desc;
			m_width = Math.abs(desc.rightBorder - desc.leftBorder);
			m_height = Math.abs(desc.bottomBorder - desc.topBorder);
		}

		/**
		 * 播放 指定动画
		 * @param dir   方向
		 * @param frame 起始帧  0开始
		 * @param loops 循环数
		 * @return
		 *
		 */
		public function gotoEffect(dir : int, frame : int, loops : int) : SAnimationFrame
		{
			m_curDir = dir;
			m_correctDir = EnumDirection.correctDirection(m_dirMode, m_correctDir, dir);
			m_curAnimation = m_animationsByPart.gotoAnimation(dir);
			m_loops = loops;
			gotoFrame(frame);
			return m_curAnimationFrame;
		}

		/**
		 * 制定播放到某一帧
		 * @param frame  从0开始
		 * @return
		 *
		 */
		public function gotoFrame(frame : int) : SAnimationFrame
		{
			if (!m_curAnimation)
				return null;
			if (frame >= totalFrame)
				frame = totalFrame;
			m_curFrameIndex = frame;
			m_curAnimationFrame = m_curAnimation.getFrame(m_curFrameIndex);
			m_isEnd = frame >= totalFrame;
			return m_curAnimationFrame;
		}

		public function gotoNextFrame(elapsedTime : int) : SAnimationFrame
		{
			if (!m_curAnimation)
				return null;
			if (!m_curAnimationFrame)
				return gotoFrame(0);
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
						m_nextFrame = getFrame(m_curFrameIndex);
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
			if (m_curFrameIndex > totalFrame)
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
					gotoFrame(m_curFrameIndex);
				}
			}
			else
			{
				gotoFrame(m_curFrameIndex);
			}
			return m_curAnimationFrame;
		}

		/**
		 * 设置当前动画库
		 * @param value
		 *
		 */
		public function set effectAnimationLibrary(value : SEffectAnimationLibrary) : void
		{
			if (m_animationsByPart)
				m_animationsByPart.release();
			m_animationsByPart = value;
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
			return m_isEnd && m_isLoopEnd;
		}

		public function get isLoopEnd() : Boolean
		{
			return m_isLoopEnd;
		}

		public function get curFrameIndex() : int
		{
			return m_curFrameIndex;
		}

		public function get totalFrame() : int
		{
			return m_curAnimation.totalFrame;
		}

		public function get isJustStarted() : Boolean
		{
			return m_isJustStarted;
		}

		public function get isPaused() : Boolean
		{
			return m_isPaused;
		}

		public function get curAnimationFrame() : SAnimationFrame
		{
			return m_curAnimationFrame;
		}

		public function getFrame(frame : int) : SAnimationFrame
		{
			return m_curAnimation.getFrame(frame);
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
			return m_curAnimation.getFrameDurations(frame);
		}

		public function get curDir() : int
		{
			return m_curDir;
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
			effectAnimationLibrary = null;
			m_effectDesc = null;
			m_curAnimation = null;
			m_curAnimationFrame = null;
			m_nextFrame = null;
		}
	}
}