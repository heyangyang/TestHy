package hy.game.avatar
{
	import flash.display.BlendMode;
	import flash.filters.BitmapFilter;
	import flash.geom.ColorTransform;
	
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
		protected var _animationFrames : Vector.<SAnimationFrame>;
		/**
		 * 当前动画帧
		 */
		protected var _curAnimationFrame : SAnimationFrame;

		/**
		 * 该动画的id
		 */
		protected var _id : String;
		/**
		 * 描述id
		 */
		protected var _descId : String;
		/**
		 * 该动作的中心基准点
		 */
		public var centerX : int;
		/**
		 * 该动作的中心基准点
		 */
		public var centerY : int;
		/**
		 * 该动画的宽度
		 */
		public var width : int;
		/**
		 * 该动画的高度
		 */
		public var height : int;

		/**
		 * 混合模式
		 */
		public var blendMode : String = BlendMode.NORMAL;
		/**
		 * 动画的层次关系  渲染深度的偏移值 身前1或身后-1
		 */
		public var depth : int;

		public var filter : BitmapFilter;

		public var colorTransform : ColorTransform;

		/**
		 * 该动画的描述符
		 */
		protected var _description : SAnimationDescription;

		protected var _needReversal : Boolean = false;

		public function SAnimation(id : String, desc : SAnimationDescription, needReversal : Boolean)
		{
			super();
			_id = id;
			initFrames(desc, needReversal);
		}


		/**
		 * 根据动画描述构建所有的帧
		 */
		private function initFrames(desc : SAnimationDescription, needReversal : Boolean = false) : void
		{
			_description = desc;
			_descId = _description.id;
			centerX = _description.centerX;
			centerY = _description.centerY;
			width = _description.width;
			height = _description.height;
			filter = _description.filter;
			blendMode = _description.blendMode;
			depth = _description.depth;
			_needReversal = needReversal;

			_animationFrames = new Vector.<SAnimationFrame>();
			var animationFrame : SAnimationFrame;
			for each (var frameDesc : SFrameDescription in _description.frameDescriptionByIndex)
			{
				animationFrame = new SAnimationFrame();
				animationFrame.frameData = null;
				animationFrame.offsetX = frameDesc.offsetX - centerX;
				animationFrame.offsetY = frameDesc.offsetY - centerY;
				animationFrame.needReversal = _needReversal;
				animationFrame.duration = frameDesc.duration;
				_animationFrames.push(animationFrame);
			}
			total_frames = _animationFrames.length;
		}


		public function get id() : String
		{
			return _id;
		}

		public function getFrame(frame : int) : SAnimationFrame
		{
			constructFrames(frame);
			if (_animationFrames && total_frames > 0)
			{
				return _animationFrames[frame];
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
			return centerX - width * 0.5;
		}

		public function get offsetY() : int
		{
			return centerY - height * 0.5;
		}

		public function get isLoaded() : Boolean
		{
			return false;
		}

		public function destroy() : void
		{
			_description = null;
			_curAnimationFrame = null;
			destroyFrames();
			filter = null;
			colorTransform = null;
		}

		public function updateCenter(centerX : int, centerY : int) : void
		{
			_description.centerX = centerX;
			_description.centerY = centerY;
			_animationFrames.length = 0;
			initFrames(_description, _needReversal);
		}

		/**
		 * 销毁所有帧
		 *
		 */
		public function destroyFrames() : void
		{
			if (_animationFrames == null)
				return;
			var len : int = _animationFrames.length;
			for each (var frame : SAnimationFrame in _animationFrames)
			{
				frame.destroy();
			}
			_animationFrames = null;
		}
	}
}