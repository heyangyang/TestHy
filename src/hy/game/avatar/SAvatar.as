package hy.game.avatar
{
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
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
		 * 默认的模型
		 */
		public static var default_avatar : SAvatar;
		private var m_isLoaded : Boolean;
		/**
		 * 是否显示预览模型
		 */
		public var defaultAvatar : Boolean;
		/**
		 * 所有部件对应的各自动画
		 */
		private var _animationsByPart : SAvatarAnimationLibrary;

		/**
		 * 当前avatar的描述
		 */
		public var avatarDesc : SAvatarDescription;
		private var _width : int;
		private var _height : int;
		//当前动画
		private var _curAnimation : SAnimation;
		private var _curAnimationFrame : SAnimationFrame;
		// 当前动作
		private var _curAction : uint = SActionType.IDLE;
		private var _curKind : uint = 0;
		//当前方向
		private var _curDir : uint = EnumDirection.EAST;
		private var _correctDir : uint = EnumDirection.EAST;
		private var _dirMode : uint = EnumDirection.DIR_MODE_HOR_ONE;

		public var mouseRect : Rectangle = new Rectangle();

		public var loaderComplement : Function;
		public var changeAnimation : Function;

		public function SAvatar(desc : SAvatarDescription)
		{
			this.avatarDesc = desc;
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
		public function gotoAnimation(action : uint, kind : uint, dir : int, frame : int, loops : int) : SAnimationFrame
		{
			if (avatarDesc == null)
			{
				warning(this, "avatarDesc=null");
				return null;
			}
			if (action != 0)
			{
				if (hasAction(action, kind))
				{
					_curAction = action;
					_curKind = kind;
				}
				else
				{
					_curAction = 0;
					_curKind = 0;
					var avaliaAction : Array = getAvaliableAction(action);
					if (avaliaAction)
					{
						_curAction = avaliaAction[0];
						_curKind = avaliaAction[1];
					}
				}
			}

			if (!_curAction)
			{
				return null;
			}

			_curDir = dir;
			_correctDir = EnumDirection.correctDirection(_dirMode, _correctDir, dir);

			if (_correctDir != 0)
			{
				if (!hasDir(_correctDir, _curAction, _curKind))
				{
					_correctDir = getAvaliableDir(0, 0);
				}
			}
			_curAnimation = _animationsByPart.gotoAnimation(_curAction, _curKind, _correctDir);
			_loops = loops;
			gotoFrame(frame);
			changeAnimation && changeAnimation();
			return _curAnimationFrame;
		}

		/**
		 * 换方向
		 * @param dir [0-7]
		 * @return
		 */
		public function gotoDirection(dir : int) : void
		{
			gotoAnimation(_curAction, _curKind, dir, curFrame, 0);
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

		public function get curAction() : uint
		{
			return _curAction;
		}

		public function get curKind() : uint
		{
			return _curKind;
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
				action = _curAction;
				kind = _curKind;
			}
			if (avatarDesc == null || action == 0)
				return false;
			var actionDesc : SAvatarActionDescription = avatarDesc.getActionDescByAction(action, kind);
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
			if (avatarDesc == null)
				return false;
			var actionDesc : SAvatarActionDescription = avatarDesc.getActionDescByAction(action, kind);
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
			if (avatarDesc && avatarDesc.getAvaliableActionByType(action))
				return avatarDesc.getAvaliableActionByType(action);
			else if (hasAction(SActionType.IDLE, 0))
				return [SActionType.IDLE, 0];
			else
				return avatarDesc.getAvaliableAction();
		}

		/**
		 * 得到一个可用的方向
		 * @return
		 */
		public function getAvaliableDir(action : uint, kind : uint) : int
		{
			if (!action)
			{
				action = _curAction;
				kind = _curKind;
			}
			var actionDesc : SAvatarActionDescription = avatarDesc.getActionDescByAction(action, kind);
			if (actionDesc)
			{
				var dirs : Array = actionDesc.directions;
				if (dirs.length > 0)
					return int(dirs[0]);
			}
			return 0;
		}

		public function dispose() : void
		{
			loaderComplement = null;
			changeAnimation = null;
			if (_animationsByPart)
			{
				_animationsByPart.release();
				_animationsByPart = null;
			}
			avatarDesc = null;
			_curAnimation = null;
		}

		/**
		 * 设置当前动画库
		 * @param value
		 *
		 */
		public function set animationsByParts(value : SAvatarAnimationLibrary) : void
		{
			if (_animationsByPart)
				_animationsByPart.release();
			_animationsByPart = value;
			if (_animationsByPart.isLoaded)
				onLoadCompleteAnimation();
			else if (default_avatar)
			{
				//_width = default_avatar.width * this.scaleX;
				//_height = default_avatar.height * this.scaleY;
			}
			//loaderAllAnimation();
		}

		public function get animationsByParts() : SAvatarAnimationLibrary
		{
			return _animationsByPart;
		}

		private function onLoadCompleteAnimation() : void
		{
			m_isLoaded = true;
			_width = Math.abs(avatarDesc.rightBorder - avatarDesc.leftBorder);
			_height = Math.abs(avatarDesc.bottomBorder - avatarDesc.topBorder);

			//加载完成，实行一次
			if (loaderComplement != null)
			{
				loaderComplement();
				loaderComplement = null;
			}
		}

		/**
		 * 加载所有动画
		 *
		 */
		public function loaderAllAnimation() : void
		{
			_animationsByPart && _animationsByPart.loaderAnimation();
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

		/**
		 * update判断
		 * @return
		 *
		 */
		public function get isLoaded() : Boolean
		{
			return m_isLoaded;
		}

		/**
		 * 实时是否加载完成
		 * @return
		 *
		 */
		public function get isLoadedNow() : Boolean
		{
			return _animationsByPart && _animationsByPart.isLoaded;
		}

		public function getEditorAvaliableDir(action : uint, kind : uint) : int
		{
			if (!action)
			{
				action = _curAction;
				kind = _curKind;
			}
			var actionDesc : SAvatarActionDescription = avatarDesc.getActionDescByAction(action, kind);
			if (actionDesc)
			{
				var dirs : Array = actionDesc.directions;
				if (dirs.length > 0)
				{
					if (dirs.indexOf(EnumDirection.SOUTH) >= 0)
						return EnumDirection.SOUTH;
					return int(dirs[0]);
				}
			}
			return 0;
		}

		public function isRolePickable(localX : int, localY : int) : Boolean
		{
			if (curAnimationFrame && curAnimationFrame.frameData)
			{
				localX -= mouseRect.left;
				localY -= mouseRect.top;

				//反转的时候，需要把坐标反转
				if (curAnimationFrame.needReversal)
					localX = curAnimationFrame.frameData.width - localX;

				var color : uint = curAnimationFrame.frameData.getPixel(localX, localY);

				if (color != 0)
				{
					return true;
				}
			}
			return false;
		}

	}
}