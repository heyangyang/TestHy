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
		protected var m_currAccessFrame : int;
		/**
		 * 该动画用到的资源解析器
		 */
		protected var m_parser : ParserAnimationResource;

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
		}

		override public function constructFrames(currAccessFrame : int) : void
		{
			m_currAccessFrame = currAccessFrame;
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
			if (onLoaderComplete != null)
			{
				onLoaderComplete();
				onLoaderComplete = null;
			}
			constructFromParser();
		}

		/**
		 *
		 * 从保存了的所有位图中根据id取出当前动画需要的所有位图
		 *
		 */
		private function constructFromParser() : void
		{
			if (m_currAccessFrame > 0 && m_currAccessFrame <= totalFrame)
			{
				if (m_parser && m_parser.isLoaded)
				{
					if (m_animationFrames.length == 0)
						error(index + "null frames=0 " + id);
					m_width = m_parser.width;
					m_height = m_parser.height;
					var index : int = m_currAccessFrame - 1;
					var frame : SAnimationFrame = m_animationFrames[index];
					if (frame.frameData)
						return;
					frame.clear();
					frame.frameData = getBitmapDataByIndex(index);
					var offset : Point = m_parser.getOffset(index, cur_dir);
					if (offset)
					{
						frame.frameX = offset.x;
						frame.frameY = offset.y;
					}
					if (!frame.frameData)
						warning(this, "帧数据为空！" + index + "   " + id);
				}
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
			if (index >= 0 && index < m_description.totalFrame)
			{
				for each (var frameDesc : SFrameDescription in m_description.frameDescriptionByIndex)
				{
					if (frameDesc.index == index + 1)
					{
						return m_parser.getBitmapDataByDir(frameDesc.frame, cur_dir);
					}
				}
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
			onLoaderComplete = null;
			parser = null;
			super.destroy();
		}
	}
}