package hy.game.animation
{
	import flash.display.BlendMode;
	import flash.filters.BitmapFilter;

	import hy.game.data.SObject;


	/**
	 *
	 * 普通动画类，动画由一组帧图片构成
	 *
	 */
	public class SAnimation extends SObject
	{
		protected var mTotal_frames : int;
		/**
		 * 动画帧序列
		 */
		protected var mAnimationFrames : Vector.<SAnimationFrame>;
		/**
		 * 描述
		 */
		protected var mDescription : SAnimationDescription;
		/**
		 * 该动画的id
		 */
		private var mId : String;
		/**
		 * 该动作的中心基准点
		 */
		private var mCenterX : int;
		/**
		 * 该动作的中心基准点
		 */
		private var mCenterY : int;
		/**
		 * 该动画的宽度
		 */
		protected var mWidth : int;
		/**
		 * 该动画的高度
		 */
		protected var mHeight : int;

		/**
		 * 混合模式
		 */
		private var mBlendMode : String = BlendMode.NORMAL;

		public var filter : BitmapFilter;

		protected var mDepth : int;

		public function SAnimation(id : String, desc : SAnimationDescription, needReversal : Boolean)
		{
			super();
			mId = id;
			initFrames(desc, needReversal);
		}


		/**
		 * 根据动画描述构建所有的帧
		 */
		private function initFrames(desc : SAnimationDescription, needReversal : Boolean = false) : void
		{
			mDescription = desc;
			mCenterX = desc.centerX;
			mCenterY = desc.centerY;
			mWidth = desc.width;
			mHeight = desc.height;
			mDepth = desc.depth;
			filter = desc.filter;
			mBlendMode = desc.blendMode;

			mAnimationFrames = new Vector.<SAnimationFrame>();
			var animationFrame : SAnimationFrame;
			for each (var frameDesc : SFrameDescription in desc.frameDescriptionByIndex)
			{
				animationFrame = new SAnimationFrame();
				animationFrame.frameData = null;
				animationFrame.offsetX = frameDesc.offsetX - mCenterX;
				animationFrame.offsetY = frameDesc.offsetY - mCenterY;
				animationFrame.needReversal = needReversal;
				animationFrame.duration = frameDesc.duration;
				mAnimationFrames.push(animationFrame);
			}
			mTotal_frames = mAnimationFrames.length - 1;
			if (mTotal_frames <= 0)
				error(desc.id + "is null frames ");
		}


		public function getFrame(frame : int) : SAnimationFrame
		{
			return null;
		}

		public function constructFrames(currAccessFrame : int) : void
		{

		}

		public function get totalFrame() : int
		{
			return mTotal_frames;
		}

		/**
		 * 获得某帧的播放时间
		 * @param frame
		 * @return
		 *
		 */
		public function getFrameDurations(frame : int = 1) : int
		{
			frame = frame - 1;
			var animationFrame : SAnimationFrame = getFrame(frame);
			if (!animationFrame)
			{
				error(this, "null frame:" + frame + "/" + totalFrame);
				return 0;
			}
			return animationFrame.duration;
		}

		public function hasFrame(index : int) : Boolean
		{
			return getFrame(index) != null;
		}

		public function get offsetX() : int
		{
			return mCenterX - mWidth * 0.5;
		}

		public function get offsetY() : int
		{
			return mCenterY - mHeight * 0.5;
		}

		public function get isLoaded() : Boolean
		{
			return false;
		}

		public function get id() : String
		{
			return mId;
		}

		public function get width() : int
		{
			return mWidth;
		}

		public function get height() : int
		{
			return mHeight;
		}


		public function get depth() : int
		{
			return mDepth;
		}


		/**
		 * 销毁所有帧
		 *
		 */
		public function destroyFrames() : void
		{
			if (mAnimationFrames == null)
				return;
			for each (var frame : SAnimationFrame in mAnimationFrames)
			{
				frame.destroy();
			}
			mAnimationFrames = null;
		}


		public function destroy() : void
		{
			mDescription = null;
			destroyFrames();
			filter = null;
		}
	}
}