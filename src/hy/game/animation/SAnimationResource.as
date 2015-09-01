package hy.game.animation
{
	import flash.geom.Point;

	import hy.game.interfaces.display.IBitmapData;
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
		private var mCurFrameIndex : int;
		private var mCurrFrameAnimation : SAnimationFrame;
		/**
		 * 处理完一次，索引加1
		 */
		private var mFinishIndex : int;
		/**
		 * 是否所有图片都处理完毕
		 */
		private var mIsFinish : Boolean;
		/**
		 * 该动画用到的资源解析器
		 */
		private var mParser : ParserAnimationResource;

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
			mFinishIndex = 0;
			mIsFinish = false;
		}

		override public function getFrame(frame : int) : SAnimationFrame
		{
			constructFrames(frame);
			return mCurrFrameAnimation;
		}

		override public function constructFrames(currAccessFrame : int) : void
		{
			mCurFrameIndex = currAccessFrame;
			mCurrFrameAnimation = mAnimationFrames[mCurFrameIndex];
			if (mIsFinish)
				return;
			if (!mParser)
			{
				parser = SReferenceManager.getInstance().createAnimationResourceParser(mDescription, priority);
			}
			if (mParser.isComplete)
			{
				constructFromParser();
			}
			else if (!mParser.isLoading)
			{
				mParser.onComplete(onCreateFrameData).load();
			}
		}

		private function onCreateFrameData(res : ParserResource) : void
		{
			mWidth = mParser.width;
			mHeight = mParser.height;
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
			if (!mCurrFrameAnimation)
				return;
			if (mParser && mParser.isComplete)
			{
				if (mCurrFrameAnimation.frameData)
					return;
				mCurrFrameAnimation.clear();
				offset = mParser.getOffset(mCurFrameIndex, cur_dir);
				if (offset)
				{
					mCurrFrameAnimation.frameX = offset.x;
					mCurrFrameAnimation.frameY = offset.y;
				}
				if (++mFinishIndex > mTotal_frames)
					mIsFinish = true;
				mCurrFrameAnimation.frameData = getBitmapDataByIndex(mCurFrameIndex);
				if (!mCurrFrameAnimation.frameData)
					warning(this, "帧数据为空！" + mCurFrameIndex + "   " + id);
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
			if (index >= 0 && index <= mTotal_frames)
			{
				var frameDesc : SFrameDescription = mDescription.frameDescriptionByIndex[index + 1];
				return mParser.getBitmapDataByDir(frameDesc.frame, cur_dir);
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
			return mParser && mParser.isComplete;
		}

		/**
		 * 设置解析器的时候，释放掉上一个解析器
		 * @param value
		 *
		 */
		private function set parser(value : ParserAnimationResource) : void
		{
			mParser && mParser.release();
			mParser = value;
		}

		override public function destroy() : void
		{
			mCurrFrameAnimation = null;
			onLoaderComplete = null;
			parser = null;
			super.destroy();
		}
	}
}