package hy.game.animation
{
	import hy.game.data.SRectangle;
	import hy.game.interfaces.display.IBitmapData;

	/**
	 *
	 * 动画帧
	 *
	 */
	public class SAnimationFrame
	{
		/**
		 * 当前帧的位图（共享）
		 */
		private var mFrameData : IBitmapData;

		/**
		 * 当前帧需要绘制的区域
		 */
		private var mRect : SRectangle;

		/**
		 * 当前帧X偏移值，此偏移为设置值
		 */
		public var offsetX : int;

		/**
		 * 当前帧Y偏移值，此偏移为设置值
		 */
		public var offsetY : int;

		/**
		 * 当前帧X偏移值，此偏移为中心点相对最小包围框左上角的偏移
		 */
		public var frameX : int;

		/**
		 * 当前帧Y偏移值，此偏移为中心点相对最小包围框左上角的偏移
		 */
		public var frameY : int;

		private var mX : int;
		private var mY : int;

		public function get x() : int
		{
			return mX;
		}

		public function get y() : int
		{
			return mY;
		}

		/**
		 * 当前帧需要播放的持续时间
		 */
		public var duration : int = 120;

		/**
		 * 需要反转
		 */
		public var needReversal : Boolean = false;

		/**
		 * 是否已经反转过了
		 */
		private var _isReversed : Boolean = false;

		/**
		 * 没有翻转的原始值
		 */
		private var _originOffsetX : int;
		private var _originOffsetY : int;
		private var _originFrameX : int;
		private var _originFrameY : int;

		public function SAnimationFrame()
		{
			super();
			mRect = new SRectangle();
		}

		public function clear() : void
		{
			if (!mFrameData)
				return;
			mFrameData = null;
			mRect.setEmpty();
			if (needReversal)
			{
				offsetX = _originOffsetX;
				offsetY = _originOffsetY;
				frameX = _originFrameX;
				frameY = _originFrameY;
			}
			mX = mY = 0;
			_isReversed = false;
		}

		/**
		 * 将位图反转
		 */
		public function reverseData() : void
		{
			//已经反转过，则直接返回
			if (_isReversed)
				return;
			_originOffsetX = offsetX;
			_originFrameX = frameX;
			frameX = offsetX - frameX;
			offsetX = -offsetX * 2;
			_isReversed = true;
			mX = frameX + offsetX;
			mY = frameY + offsetY;
		}

		public function get frameData() : IBitmapData
		{
			return mFrameData;
		}

		public function set frameData(value : IBitmapData) : void
		{
			mFrameData = value;
			_isReversed = false;
			if (mFrameData)
			{
				mX = frameX + offsetX;
				mY = frameY + offsetY;
				mRect.updateRectangle(x, y, mFrameData.width, mFrameData.height);
			}
		}


		public function get rect() : SRectangle
		{
			return mRect;
		}

		public function destroy() : void
		{
			clear();
			mFrameData = null;
			mRect = null;
			duration = 120;
			mX = mY = 0;
			offsetX = offsetY = frameX = frameY = 0;
			_originOffsetX = _originOffsetY = _originFrameX = _originFrameY = 0;
			needReversal = _isReversed = false;
		}
	}
}