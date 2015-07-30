package hy.game.aEffect
{
	import hy.game.animation.SAnimation;
	import hy.game.animation.SAnimationFrame;
	import hy.game.data.SObject;
	import hy.rpg.enmu.SDirection;

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
		private var _animationsByPart : SEffectAnimationLibrary;

		/**
		 * 当前avatar的描述
		 */
		public var effectDesc : SEffectDescription;
		private var _width : int;
		private var _height : int;
		//当前动画
		private var _curAnimation : SAnimation;
		private var _curAnimationFrame : SAnimationFrame;
		//当前方向
		private var _curDir : uint = SDirection.EAST;
		private var _correctDir : uint = SDirection.EAST;
		private var _dirMode : uint = SDirection.DIR_MODE_HOR_ONE;

		public function SEffect(desc : SEffectDescription)
		{
			this.effectDesc = desc;
			_width = Math.abs(desc.rightBorder - desc.leftBorder);
			_height = Math.abs(desc.bottomBorder - desc.topBorder);
		}

		/**
		 * 播放 指定动画
		 * @param action  动作名称
		 * @param dir 方向
		 * @param index 跳到 Frame
		 * @return
		 *
		 */
		public function gotoAnimation(dir : int, frame : int, loops : int) : SAnimationFrame
		{
			if (effectDesc == null)
			{
				warning(this, "effectDesc=null");
				return null;
			}
			_curDir = dir;
			_correctDir = SDirection.correctDirection(_dirMode, _correctDir, dir);
			_curAnimation = _animationsByPart.gotoAnimation(dir);
			_loops = loops;
			gotoFrame(frame);
			return _curAnimationFrame;
		}

		/**
		 * 当前动画已持续的时间
		 */
		protected var _curAnimationDurations : int;

		/**
		 * 当前帧逝去时间
		 */
		protected var _curFrameElapsedTime : int;

		/**
		 * 当前帧持续的时间
		 */
		protected var _curFrameDuration : int;

		/**
		 * 当前的动画帧索引
		 */
		protected var _curFrameIndex : int;

		/**
		 * 是否暂停播放
		 */
		protected var _isPaused : Boolean;

		/**
		 * 当前帧是否到最后一帧
		 */
		protected var _isEnd : Boolean;

		/**
		 *  是否播放次数结束
		 */
		protected var _isLoopEnd : Boolean;


		/**
		 * 刚开始播放
		 */
		protected var _isJustStarted : Boolean;

		/**
		 * 动画总共需要循环的次数
		 */
		protected var _loops : int = 0;

		/**
		 * 当前已经循环的次数
		 */
		protected var _curLoop : int;

		public function gotoNextFrame(elapsedTime : int, frameDuration : int = 0, durationScale : Number = 1, checkAttackFrame : Boolean = false) : SAnimationFrame
		{
			if (!_curAnimation)
				return null;
			if (!_curAnimationFrame)
				return gotoFrame(1);
			if (_isPaused)
				return _curAnimationFrame;

			if (frameDuration == 0)
				frameDuration = _curAnimationFrame.duration;

			if (durationScale != 1)
				frameDuration = Math.round(frameDuration * durationScale);

			_isJustStarted = false;

			_curFrameElapsedTime += elapsedTime;
			_curAnimationDurations += elapsedTime;

			//如果该帧停留的次数超过了定义的次数，获取下一帧
			if (_curFrameElapsedTime >= frameDuration)
			{
				//要强制跳的帧数
				var skipFrames : int = (frameDuration > 0 ? (_curFrameElapsedTime / frameDuration) : _curFrameElapsedTime);
				if (skipFrames >= 2)
				{
					var nextFrame : SAnimationFrame;
					//大于一帧的跳帧情况
					do
					{
						_curFrameElapsedTime -= frameDuration;
						_curFrameIndex += 1;
						if (_curFrameIndex >= totalFrame)
						{
							_curFrameIndex = totalFrame;
							break;
						}
						else
						{
							frameDuration = 0;
							nextFrame = getFrame(_curFrameIndex + 1);
							if (nextFrame)
							{
								frameDuration = nextFrame.duration;
								if (durationScale != 1)
									frameDuration = Math.round(frameDuration * durationScale);
							}
						}
					} while (_curFrameElapsedTime >= frameDuration)
				}
				else
				{
					//求余值 
					_curFrameElapsedTime = _curFrameElapsedTime % frameDuration;
					_curFrameIndex += skipFrames;
				}

				//如果播放到动画尾，重新从第一帧开始播放
				if (_curFrameIndex >= totalFrame)
				{
					_curLoop++;
					//从0帧开始跳转 当前帧索引 相对于 总帧数 的余数
					var startFameIndex : int = _curFrameIndex % totalFrame;
					//如果需要记录结束 ，则不跳转
					if (_loops > 0 && _curLoop >= _loops)
					{
						gotoFrame(totalFrame);
						_isLoopEnd = true;
					}
					else
					{
						_curAnimationDurations = 0;
						_isJustStarted = true;
						gotoFrame(startFameIndex + 1);
					}
				}
				else
				{
					gotoFrame(_curFrameIndex + 1);
				}
			}
			_curFrameDuration = frameDuration;

			if (_curFrameIndex >= totalFrame && _curFrameElapsedTime >= frameDuration)
				_isEnd = true;
			return _curAnimationFrame;
		}

		public function gotoFrame(frame : int) : SAnimationFrame
		{
			if (!_curAnimation)
				return null;
			if (frame < 1)
				frame = 1;
			if (frame > totalFrame)
				frame = totalFrame;
			_curFrameElapsedTime = 0;
			_curFrameIndex = frame - 1;

			if (_curAnimation)
			{
				_curAnimation.constructFrames(frame);
				_curAnimationFrame = _curAnimation.getFrame(_curFrameIndex);
				while (_curAnimationFrame && _curAnimationFrame.duration <= 0)
				{
					frame++;
					_curFrameIndex = frame - 1;
					if (_curFrameIndex >= 0 && _curFrameIndex < totalFrame)
					{
						_curAnimation.constructFrames(frame);
						_curAnimationFrame = _curAnimation.getFrame(_curFrameIndex);
					}
					else
					{
						frame = totalFrame;
						_curFrameIndex = frame - 1;
						_curAnimation.constructFrames(frame);
						_curAnimationFrame = _curAnimation.getFrame(_curFrameIndex);
						break;
					}
				}
			}
			if (frame < totalFrame)
				_isEnd = false;
			else
				_isEnd = true;
			return _curAnimationFrame;
		}

		// 暂定播放动画
		public function pause() : void
		{
			_isPaused = true;
		}

		// 恢复播放动画
		public function resume(elapsedTime : int = 0) : void
		{
			_isPaused = false;
			_curFrameElapsedTime = 0;
			_isEnd = false;
			_isLoopEnd = false;
			_curAnimationDurations = 0;
			_isJustStarted = true;
			_curLoop = 0;
		}

		public function get isEnd() : Boolean
		{
			if (!_curAnimation)
				return false;
			return _isEnd && _isLoopEnd;
		}

		public function get isLoopEnd() : Boolean
		{
			return _curAnimation ? _isLoopEnd : false;
		}

		public function get curFrameIndex() : int
		{
			return _curAnimation ? _curFrameIndex : 0;
		}

		public function get curFrame() : int
		{
			return _curAnimation ? _curFrameIndex + 1 : 1;
		}

		public function get totalFrame() : int
		{
			return _curAnimation ? _curAnimation.totalFrame : 1;
		}

		public function get isJustStarted() : Boolean
		{
			return _curAnimation ? _isJustStarted : true;
		}

		public function get isPaused() : Boolean
		{
			return _curAnimation ? _isPaused : true;
		}

		public function get curAnimationFrame() : SAnimationFrame
		{
			return _curAnimation ? _curAnimationFrame : null;
		}

		public function getFrame(frame : int) : SAnimationFrame
		{
			return _curAnimation ? _curAnimation.getFrame(frame - 1) : null;
		}

		public function get loops() : int
		{
			return _loops;
		}

		public function set loops(value : int) : void
		{
			_loops = value;
		}

		public function get curAnimationDurations() : int
		{
			return _curAnimationDurations;
		}

		public function getFrameDurations(frame : int = 1) : int
		{
			return _curAnimation ? _curAnimation.getFrameDurations(frame) : 0;
		}

		public function get curDir() : int
		{
			return _curDir;
		}

		/**
		 * 设置当前动画库
		 * @param value
		 *
		 */
		public function set animationsByParts(value : SEffectAnimationLibrary) : void
		{
			if (_animationsByPart)
				_animationsByPart.release();
			_animationsByPart = value;
		}

		public function get width() : int
		{
			return _width;
		}

		public function set width(value : int) : void
		{
			if (_width != value)
				_width = value;
		}

		public function get height() : int
		{
			return _height;
		}

		public function set height(value : int) : void
		{
			if (_height != value)
				_height = value;
		}

		public function get animation_width() : int
		{
			return _curAnimation ? _curAnimation.width : 0;
		}

		public function get animation_height() : int
		{
			return _curAnimation ? _curAnimation.height : 0;
		}

		public function get offsetX() : int
		{
			return _curAnimation ? _curAnimation.offsetX : 0;
		}

		public function get offsetY() : int
		{
			return _curAnimation ? _curAnimation.offsetY : 0;
		}

		public function get hasAnimation() : Boolean
		{
			return _curAnimation != null;
		}

		public function get correctDir() : uint
		{
			return _correctDir;
		}

		public function set dirMode(value : uint) : void
		{
			_dirMode = value;
		}

		public function get dirMode() : uint
		{
			return _dirMode;
		}

		public function dispose() : void
		{
			if (_animationsByPart)
			{
				_animationsByPart.release();
				_animationsByPart = null;
			}
			effectDesc = null;
			_curAnimation = null;
		}
	}
}