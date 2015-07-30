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
		protected var total_frames : int;
		/**
		 * 动画帧序列
		 */
		protected var m_animationFrames : Vector.<SAnimationFrame>;
		/**
		 * 描述
		 */
		protected var m_description : SAnimationDescription;
		/**
		 * 该动画的id
		 */
		private var m_id : String;
		/**
		 * 该动作的中心基准点
		 */
		private var m_centerX : int;
		/**
		 * 该动作的中心基准点
		 */
		private var m_centerY : int;
		/**
		 * 该动画的宽度
		 */
		protected var m_width : int;
		/**
		 * 该动画的高度
		 */
		protected var m_height : int;

		/**
		 * 混合模式
		 */
		private var m_blendMode : String = BlendMode.NORMAL;

		public var filter : BitmapFilter;
		
		protected var m_depth:int;

		public function SAnimation(id : String, desc : SAnimationDescription, needReversal : Boolean)
		{
			super();
			m_id = id;
			initFrames(desc, needReversal);
		}


		/**
		 * 根据动画描述构建所有的帧
		 */
		private function initFrames(desc : SAnimationDescription, needReversal : Boolean = false) : void
		{
			m_description = desc;
			m_centerX = desc.centerX;
			m_centerY = desc.centerY;
			m_width = desc.width;
			m_height = desc.height;
			m_depth=desc.depth;
			filter = desc.filter;
			m_blendMode = desc.blendMode;

			m_animationFrames = new Vector.<SAnimationFrame>();
			var animationFrame : SAnimationFrame;
			for each (var frameDesc : SFrameDescription in desc.frameDescriptionByIndex)
			{
				animationFrame = new SAnimationFrame();
				animationFrame.frameData = null;
				animationFrame.offsetX = frameDesc.offsetX - m_centerX;
				animationFrame.offsetY = frameDesc.offsetY - m_centerY;
				animationFrame.needReversal = needReversal;
				animationFrame.duration = frameDesc.duration;
				m_animationFrames.push(animationFrame);
			}
			total_frames = m_animationFrames.length;
		}


		public function getFrame(frame : int) : SAnimationFrame
		{
			constructFrames(frame);
			if (m_animationFrames && total_frames > 0)
			{
				return m_animationFrames[frame];
			}
			return null;
		}

		public function constructFrames(currAccessFrame : int) : void
		{

		}

		public function get totalFrame() : int
		{
			return total_frames == 0 ? 1 : total_frames;
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
			return m_centerX - m_width * 0.5;
		}

		public function get offsetY() : int
		{
			return m_centerY - m_height * 0.5;
		}

		public function get isLoaded() : Boolean
		{
			return false;
		}

		public function get id() : String
		{
			return m_id;
		}

		public function get width() : int
		{
			return m_width;
		}

		public function get height() : int
		{
			return m_height;
		}
		
		
		public function get depth() : int
		{
			return m_depth;
		}
		

		/**
		 * 销毁所有帧
		 *
		 */
		public function destroyFrames() : void
		{
			if (m_animationFrames == null)
				return;
			var len : int = m_animationFrames.length;
			for each (var frame : SAnimationFrame in m_animationFrames)
			{
				frame.destroy();
			}
			m_animationFrames = null;
		}


		public function destroy() : void
		{
			destroyFrames();
			filter = null;
		}
	}
}