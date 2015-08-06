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
		private var lazyEffect : SEffectResource;
		private var m_effect : SEffect;
		private var m_loops : int;
		private var m_x : int;
		private var m_y : int;
		private var animationFrame : SAnimationFrame;

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
			lazyEffect = new SEffectResource();
			lazyEffect.priority = EnumLoadPriority.EFFECT;
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
			m_effect = null;
			animationFrame = null;
		}

		/**
		 * 默认值为0
		 * @param value
		 *
		 */
		public function setLoops(value : int) : void
		{
			m_loops = value;
		}

		public function setPosition(x : int, y : int) : void
		{
			m_x = x;
			m_y = y;
		}

		public function setLayer(value : int) : void
		{
			m_render.layer = value;
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
			m_render.x = m_x + animationFrame.x + m_offsetX;
			m_render.y = m_y + animationFrame.y + m_offsetY;
		}

		/**
		 * 设置特效id
		 * @param id
		 *
		 */
		public function setEffectId(id : String) : void
		{
			lazyEffect.setEffectId(id);
		}

		/**
		 * 加载完成
		 * @param effect
		 *
		 */
		protected function onLoadEffectComplete(effect : SEffect) : void
		{
			m_effect = effect;
			m_effect.gotoAnimation(m_transform.dir, 0, m_loops);
			m_render.depth = m_render.y;
		}

		override public function destroy() : void
		{
			super.destroy();
			lazyEffect && lazyEffect.destroy();
			lazyEffect = null;
		}
	}
}