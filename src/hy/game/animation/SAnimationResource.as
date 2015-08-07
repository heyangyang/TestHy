package hy.game.animation
{
	import flash.geom.Point;

	import hy.game.core.interfaces.IBitmapData;
	import hy.game.manager.SReferenceManager;
	import hy.rpg.enum.EnumLoadPriority;
	import hy.rpg.parser.ParserAnimationResource;
	import hy.rpg.parser.ParserResource;

	/**
	 * 动画加载器
	 * @author hyy
	 *
	 */
	public class SAnimationResource extends SAnimation
	{
		private static var offset : Point;
		private var m_curFrameIndex : int;
		private var m_currFrameAnimation : SAnimationFrame;
		/**
		 * 处理完一次，索引加1
		 */
		private var m_finishIndex : int;
		/**
		 * 是否所有图片都处理完毕
		 */
		private var m_isFinish : Boolean;
		/**
		 * 该动画用到的资源解析器
		 */
		private var m_parser : ParserAnimationResource;

		/**
		 * 加完完成后处理,只实行一次
		 */
		public var onLoaderComplete : Function;

		public var priority : int = EnumLoadPriority.EFFECT;

		private var cur_dir : String;

		public function SAnimationResource(id : String, desc : SAnimationDescription, needReversal : Boolean = false)
		{
			super(id, desc, needReversal);
			cur_dir = desc.id.substring(desc.id.length - 1);
			m_finishIndex = 0;
			m_isFinish = false;
		}

		override public function getFrame(frame : int) : SAnimationFrame
		{
			constructFrames(frame);
			return m_currFrameAnimation;
		}

		override public function constructFrames(currAccessFrame : int) : void
		{
			m_curFrameIndex = currAccessFrame;
			m_currFrameAnimation = m_animationFrames[m_curFrameIndex];
			if (m_isFinish)
				return;
			if (!m_parser)
			{
				parser = SReferenceManager.getInstance().createAnimationResourceParser(m_description, priority);
			}
			if (m_parser.isLoaded)
			{
				constructFromParser();
			}
			else if (!m_parser.isLoading)
			{
				m_parser.onComplete(onCreateFrameData).load();
			}
		}

		private function onCreateFrameData(res : ParserResource) : void
		{
			m_width = m_parser.width;
			m_height = m_parser.height;
			constructFromParser();
			if (onLoaderComplete != null)
			{
				onLoaderComplete();
				onLoaderComplete = null;
			}
		}

		/**
		 *
		 * 从保存了的所有位图中根据id取出当前动画需要的所有位图
		 *
		 */
		private function constructFromParser() : void
		{
			if (!m_currFrameAnimation)
				return;
			if (m_parser && m_parser.isLoaded)
			{
				if (m_currFrameAnimation.frameData)
					return;
				m_currFrameAnimation.clear();
				offset = m_parser.getOffset(m_curFrameIndex, cur_dir);
				if (offset)
				{
					m_currFrameAnimation.frameX = offset.x;
					m_currFrameAnimation.frameY = offset.y;
				}
				if (++m_finishIndex >= total_frames)
					m_isFinish = true;
				m_currFrameAnimation.frameData = getBitmapDataByIndex(m_curFrameIndex);
				if (!m_currFrameAnimation.frameData)
					warning(this, "帧数据为空！" + m_curFrameIndex + "   " + id);
			}
		}

		/**
		 * 从解析器里面获得图片
		 * @param index
		 * @return
		 *
		 */
		private function getBitmapDataByIndex(index : int) : IBitmapData
		{
			if (index >= 0 && index <= total_frames)
			{
				var frameDesc : SFrameDescription = m_description.frameDescriptionByIndex[index + 1];
				return m_parser.getBitmapDataByDir(frameDesc.frame, cur_dir);
			}
			else
			{
				error(this, "帧索引溢出！");
			}
			return null;
		}

		/**
		 * 是否加载完成
		 * @return
		 *
		 */
		override public function get isLoaded() : Boolean
		{
			return m_parser && m_parser.isLoaded;
		}

		/**
		 * 设置解析器的时候，释放掉上一个解析器
		 * @param value
		 *
		 */
		private function set parser(value : ParserAnimationResource) : void
		{
			m_parser && m_parser.release();
			m_parser = value;
		}

		override public function destroy() : void
		{
			m_currFrameAnimation = null;
			onLoaderComplete = null;
			parser = null;
			super.destroy();
		}
	}
}