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
		private var mAnimationsByPart : SEffectAnimationLibrary;

		/**
		 * 当前avatar的描述
		 */
		private var mEffectDesc : SEffectDescription;
		/**
		 * 宽
		 */
		protected var mWidth : int;
		/**
		 * 高
		 */
		protected var mHeight : int;
		/**
		 * 当前动画
		 */
		protected var mCurAnimation : SAnimation;
		/**
		 * 当前动画帧
		 */
		protected var mCurAnimationFrame : SAnimationFrame;
		/**
		 * 方向
		 */
		protected var mCurDir : uint;
		protected var mCorrectDir : uint;
		protected var mDirMode : uint;
		/**
		 * 当前帧逝去时间
		 */
		protected var mCurFrameElapsedTime : int;
		/**
		 * 当前帧持续的时间
		 */
		protected var mCurFrameDuration : int;
		/**
		 * 当前的动画帧索引,从0开始
		 */
		protected var mCurFrameIndex : int;
		/**
		 * 是否暂停播放
		 */
		protected var mIsPaused : Boolean;

		/**
		 * 当前帧是否到最后一帧
		 */
		protected var mIsEnd : Boolean;
		/**
		 *  是否播放次数结束
		 */
		protected var mIsLoopEnd : Boolean;
		/**
		 * 刚开始播放
		 */
		protected var mIsJustStarted : Boolean;
		/**
		 * 动画总共需要循环的次数
		 */
		protected var mLoops : int;
		/**
		 * 当前已经循环的次数
		 */
		protected var mCurLoop : int;
		/**
		 * 跳帧
		 */
		protected var mSkipFrames : int
		/**
		 * 下一帧
		 */
		protected var mNextFrame : SAnimationFrame;

		public function SEffect()
		{

		}

		public function initEffect(desc : SEffectDescription) : void
		{
			mEffectDesc = desc;
			mWidth = Math.abs(desc.rightBorder - desc.leftBorder);
			mHeight = Math.abs(desc.bottomBorder - desc.topBorder);
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
			mCurDir = dir;
			mCorrectDir = EnumDirection.correctDirection(mDirMode, mCorrectDir, dir);
			mCurAnimation = mAnimationsByPart.gotoAnimation(dir);
			mLoops = loops;
			gotoFrame(frame);
			return mCurAnimationFrame;
		}

		/**
		 * 制定播放到某一帧
		 * @param frame  从0开始
		 * @return
		 *
		 */
		public function gotoFrame(frame : int) : SAnimationFrame
		{
			if (!mCurAnimation)
				return null;
			if (frame >= totalFrame)
				frame = totalFrame;
			mCurFrameIndex = frame;
			mCurAnimationFrame = mCurAnimation.getFrame(mCurFrameIndex);
			mIsEnd = frame >= totalFrame;
			return mCurAnimationFrame;
		}

		public function gotoNextFrame(elapsedTime : int) : SAnimationFrame
		{
			if (!mCurAnimation)
				return null;
			if (!mCurAnimationFrame)
				return gotoFrame(0);
			if (mIsPaused)
				return mCurAnimationFrame;

			mIsJustStarted = false;
			mCurFrameDuration = mCurAnimationFrame.duration;
			mCurFrameElapsedTime += elapsedTime;

			if (mCurFrameElapsedTime < mCurFrameDuration)
				return mCurAnimationFrame;
			//要强制跳的帧数
			mSkipFrames = mCurFrameElapsedTime / mCurFrameDuration;
			//大于一帧的跳帧情况
			if (mSkipFrames > 1)
			{
				do
				{
					mCurFrameElapsedTime -= mCurFrameDuration;
					mCurFrameIndex += 1;
					if (mCurFrameIndex >= totalFrame)
					{
						mCurFrameIndex = totalFrame;
						break;
					}
					else
					{
						mNextFrame = getFrame(mCurFrameIndex);
						mCurFrameDuration = mNextFrame.duration;
					}
				} while (mCurFrameElapsedTime >= mCurFrameDuration)
			}
			else
			{
				//求余值 
				mCurFrameElapsedTime = mCurFrameElapsedTime % mCurFrameDuration;
				mCurFrameIndex += mSkipFrames;
			}

			//如果播放到动画尾，重新从第一帧开始播放
			if (mCurFrameIndex > totalFrame)
			{
				mCurLoop++;
				//从0帧开始跳转 当前帧索引 相对于 总帧数 的余数
				mCurFrameIndex = mCurFrameIndex % totalFrame;
				//如果需要记录结束 ，则不跳转
				if (mLoops > 0 && mCurLoop >= mLoops)
				{
					gotoFrame(totalFrame);
					mIsLoopEnd = true;
				}
				else
				{
					mIsJustStarted = true;
					gotoFrame(mCurFrameIndex);
				}
			}
			else
			{
				gotoFrame(mCurFrameIndex);
			}
			return mCurAnimationFrame;
		}

		/**
		 * 设置当前动画库
		 * @param value
		 *
		 */
		public function set effectAnimationLibrary(value : SEffectAnimationLibrary) : void
		{
			if (mAnimationsByPart)
				mAnimationsByPart.release();
			mAnimationsByPart = value;
		}

		// 暂定播放动画
		public function pause() : void
		{
			mIsPaused = true;
		}

		// 恢复播放动画
		public function resume(elapsedTime : int = 0) : void
		{
			mIsPaused = false;
			mCurFrameElapsedTime = 0;
			mIsEnd = false;
			mIsLoopEnd = false;
			mIsJustStarted = true;
			mCurLoop = 0;
		}

		public function get isEnd() : Boolean
		{
			return mIsEnd && mIsLoopEnd;
		}

		public function get isLoopEnd() : Boolean
		{
			return mIsLoopEnd;
		}

		public function get curFrameIndex() : int
		{
			return mCurFrameIndex;
		}

		public function get totalFrame() : int
		{
			return mCurAnimation.totalFrame;
		}

		public function get isJustStarted() : Boolean
		{
			return mIsJustStarted;
		}

		public function get isPaused() : Boolean
		{
			return mIsPaused;
		}

		public function get curAnimationFrame() : SAnimationFrame
		{
			return mCurAnimationFrame;
		}

		public function getFrame(frame : int) : SAnimationFrame
		{
			return mCurAnimation.getFrame(frame);
		}

		public function get loops() : int
		{
			return mLoops;
		}

		public function set loops(value : int) : void
		{
			mLoops = value;
		}

		public function getFrameDurations(frame : int = 1) : int
		{
			return mCurAnimation.getFrameDurations(frame);
		}

		public function get curDir() : int
		{
			return mCurDir;
		}

		public function get width() : int
		{
			return mWidth;
		}

		public function set width(value : int) : void
		{
			if (mWidth != value)
				mWidth = value;
		}

		public function get height() : int
		{
			return mHeight;
		}

		public function set height(value : int) : void
		{
			if (mHeight != value)
				mHeight = value;
		}

		public function get correctDir() : uint
		{
			return mCorrectDir;
		}

		public function set dirMode(value : uint) : void
		{
			mDirMode = value;
		}

		public function get dirMode() : uint
		{
			return mDirMode;
		}

		public function dispose() : void
		{
			effectAnimationLibrary = null;
			mEffectDesc = null;
			mCurAnimation = null;
			mCurAnimationFrame = null;
			mNextFrame = null;
		}
	}
}