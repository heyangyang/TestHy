package hy.game.components
{
	import hy.game.aEffect.SEffect;
	import hy.game.aEffect.SEffectResource;
	import hy.game.animation.SAnimationFrame;
	import hy.game.core.STime;
	import hy.game.namespaces.name_part;
	import hy.rpg.enum.EnumLoadPriority;

	use namespace name_part;

	/**
	 * 动画组件
	 * @author hyy
	 *
	 */
	public class SAnimationComponent extends SRenderComponent
	{
		private var mResource : SEffectResource;
		private var mEffect : SEffect;
		private var mCurrFrame : SAnimationFrame;
		private var mUpdateFrame : SAnimationFrame;
		private var mLoops : int;
		private var mX : int;
		private var mY : int;

		public function SAnimationComponent(type : * = null)
		{
			super(type);
		}

		/**
		 * 继承的子类，必须调用该类方法
		 *
		 */
		override protected function init() : void
		{
			super.init();
			mResource = new SEffectResource();
			mResource.priority = EnumLoadPriority.EFFECT;
		}

		/**
		 * 继承的子类，必须调用该类方法
		 *
		 */
		override protected function onStart() : void
		{
			super.onStart();
		}

		/**
		 * 继承的子类，必须调用该类方法
		 *
		 */
		override public function notifyRemoved() : void
		{
			super.notifyRemoved();
			mEffect = null;
			mCurrFrame = null;
			mUpdateFrame = null;
		}

		/**
		 * 默认值为0
		 * @param value
		 *
		 */
		public function setLoops(value : int) : void
		{
			mLoops = value;
		}

		public function setPosition(x : int, y : int) : void
		{
			mX = x;
			mY = y;
		}

		public function setLayer(value : int) : void
		{
			mRender.layer = value;
		}

		override public function update() : void
		{
			if (mResource.isChange)
			{
				mResource.addNotifyCompleted(onLoadEffectComplete);
				mResource.loadResource();
			}
			if (!mEffect)
				return;
			if (mEffect.isEnd)
			{
				destroy();
				return;
			}
			mUpdateFrame = mEffect.gotoNextFrame(STime.deltaTime);
			if (!mUpdateFrame || mUpdateFrame == mCurrFrame)
				return;
			mCurrFrame = mUpdateFrame;
			mRender.bitmapData = mCurrFrame.frameData;
			mRender.x = mX + mCurrFrame.x + mOffsetX;
			mRender.y = mY + mCurrFrame.y + mOffsetY;
		}

		/**
		 * 设置特效id
		 * @param id
		 *
		 */
		public function setEffectId(id : String) : void
		{
			mResource.setEffectId(id);
		}

		/**
		 * 加载完成
		 * @param effect
		 *
		 */
		protected function onLoadEffectComplete(effect : SEffect) : void
		{
			mEffect = effect;
			mEffect.gotoEffect(mTransform.dir, 0, mLoops);
			mRender.depth = mRender.y;
		}

		override public function destroy() : void
		{
			super.destroy();
			mResource && mResource.destroy();
			mResource = null;
		}
	}
}