package hy.game.avatar
{
	import flash.geom.Point;
	
	import hy.game.cfg.Config;
	import hy.game.core.interfaces.IBitmapData;
	import hy.game.manager.SReferenceManager;
	import hy.rpg.enmu.SLoadPriorityType;
	import hy.rpg.parser.SAnimationResourceParser;
	import hy.rpg.parser.SResourceParser;

	public class SLazyAnimation extends SAnimation
	{
		protected var _currAccessFrame : int;
		/**
		 * 该动画用到的资源解析器
		 */
		protected var _parser : SAnimationResourceParser;

		/**
		 * 加完完成后处理,只实行一次
		 */
		public var onLoaderComplete : Function;

		public var priority : int = SLoadPriorityType.EFFECT;

		public function SLazyAnimation(id : String, desc : SAnimationDescription, needReversal : Boolean = false)
		{
			super(id, desc, needReversal);
		}

		override public function constructFrames(currAccessFrame : int) : void
		{
			_currAccessFrame = currAccessFrame;
			if (!_parser)
			{
				parser = SReferenceManager.getInstance().createAnimationResourceParser(_description, priority, Config.supportDirectX);
			}
			if (_parser.isLoaded)
			{
				constructFromParser();
			}
			else if (!_parser.isLoading)
			{
				_parser.onComplete(onCreateFrameData).load();
			}
		}

		private function onCreateFrameData(res : SResourceParser) : void
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
			if (_currAccessFrame > 0 && _currAccessFrame <= totalFrame)
			{
				if (_parser && _parser.isLoaded)
				{
					if (_animationFrames.length == 0)
						error(index + "null frames=0 " + id);
					width = _parser.width;
					height = _parser.height;
					var index : int = _currAccessFrame - 1;
					var frame : SAnimationFrame = _animationFrames[index];
					if (frame.frameData)
						return;
					frame.clear();
					frame.frameData = getBitmapDataByIndex(index);
					var offset : Point = _parser.getOffset(index);
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
			if (index >= 0 && index < _description.totalFrame)
			{
				for each (var frameDesc : SFrameDescription in _description.frameDescriptionByIndex)
				{
					if (frameDesc.index == index + 1)
					{
						return _parser.getBitmapDataByDir(frameDesc.frame);
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
			return _parser && _parser.isLoaded;
		}

		/**
		 * 设置解析器的时候，释放掉上一个解析器
		 * @param value
		 *
		 */
		private function set parser(value : SAnimationResourceParser) : void
		{
			if (_parser)
				_parser.release();
			_parser = value;
		}

		override public function destroy() : void
		{
			onLoaderComplete = null;
			parser = null;
			super.destroy();
		}
	}
}