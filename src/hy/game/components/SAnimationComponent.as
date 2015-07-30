package hy.game.components
{
	import hy.game.aEffect.SEffect;
	import hy.game.aEffect.SLazyEffect;
	import hy.game.avatar.SActionType;
	import hy.game.avatar.SAvatar;
	import hy.rpg.enmu.SDirection;
	import hy.rpg.enmu.SLoadPriorityType;

	/**
	 * 动画组件
	 * @author hyy
	 *
	 */
	public class SAnimationComponent extends SRenderComponent
	{
		private var lazyEffect : SLazyEffect;
		private var m_effect : SEffect;

		public function SAnimationComponent(type : * = null)
		{
			super(type);
			lazyEffect = new SLazyEffect();
			lazyEffect.priority = SLoadPriorityType.EFFECT;
		}

		override public function notifyAdded() : void
		{
			super.notifyAdded();
		}

		public function setEffectId(id : String) : void
		{
			lazyEffect.setEffectId(id);
			if (!lazyEffect.isChange)
				return;
			lazyEffect.addNotifyCompleted(onLoadEffectComplete);
			lazyEffect.loadResource();
		}

		private function onLoadEffectComplete(effect : SEffect) : void
		{
			m_effect = effect;
			m_owner.transform.width = m_effect.width;
			m_owner.transform.height = m_effect.height;
			m_effect.gotoAnimation(SDirection.SOUTH, 0, 1);
		}
	}
}