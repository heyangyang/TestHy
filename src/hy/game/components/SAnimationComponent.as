package hy.game.components
{
	import hy.game.aEffect.SEffect;
	import hy.game.aEffect.SEffectResource;
	import hy.game.animation.SAnimationFrame;
	import hy.game.core.STime;
	import hy.rpg.enum.EnumLoadPriority;

	/**
	 * 动画组件
	 * @author hyy
	 *
	 */
	public class SAnimationComponent extends SRenderComponent
	{
		private var lazyEffect : SEffectResource;
		private var m_effect : SEffect;
		private var m_loops : int;
		private var animationFrame : SAnimationFrame;

		public function SAnimationComponent(type : * = null)
		{
			super(type);
			lazyEffect = new SEffectResource();
			lazyEffect.priority = EnumLoadPriority.EFFECT;
		}

		public function setLoops(value : int) : void
		{
			m_loops = value;
		}

		override public function notifyAdded() : void
		{
			super.notifyAdded();
		}

		override public function update() : void
		{
			if (lazyEffect.isChange)
			{
				lazyEffect.addNotifyCompleted(onLoadEffectComplete);
				lazyEffect.loadResource();
			}
			if (!m_effect)
				return;
			if (m_effect.isEnd)
			{
				destroy();
				return;
			}
			var frame : SAnimationFrame = m_effect.gotoNextFrame(STime.deltaTime);
			if (!frame || frame == animationFrame)
				return;
			animationFrame = frame;
			m_render.bitmapData = animationFrame.frameData;
			m_render.x = animationFrame.x + m_offsetX;
			m_render.y = animationFrame.y + m_offsetY;
		}

		public function setEffectId(id : String) : void
		{
			lazyEffect.setEffectId(id);
		}

		private function onLoadEffectComplete(effect : SEffect) : void
		{
			m_effect = effect;
			m_effect.gotoAnimation(m_transform.dir, 0, m_loops);
			m_render.layer = m_effect.depth;
		}

		override public function destroy() : void
		{
			super.destroy();
			lazyEffect && lazyEffect.destroy();
			m_effect = null;
		}
	}
}