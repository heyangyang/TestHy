package hy.game.components
{
	import hy.game.animation.SAnimationFrame;
	import hy.game.avatar.SActionType;
	import hy.game.avatar.SAvatar;
	import hy.game.avatar.SLazyAvatar;
	import hy.game.cfg.Time;
	import hy.rpg.enmu.SDirection;
	import hy.rpg.enmu.SLoadPriorityType;

	/**
	 * 人物模型组件
	 * @author hyy
	 *
	 */
	public class SAvatarComponent extends SRenderComponent
	{
		private var m_lazyAvatar : SLazyAvatar;
		private var m_avatar : SAvatar;
		private var animationFrame : SAnimationFrame;

		public function SAvatarComponent(type : * = null)
		{
			super(type);
			m_lazyAvatar = new SLazyAvatar();
			m_lazyAvatar.defaultAvatar = true;
			m_lazyAvatar.priority = SLoadPriorityType.ROLE;
		}

		override public function notifyAdded() : void
		{
			super.notifyAdded();
		}

		override public function update() : void
		{
			if (!m_avatar)
				return;
			var frame : SAnimationFrame = m_avatar.gotoNextFrame(Time.deltaTime);
			if (!frame || frame == animationFrame)
				return;
			animationFrame = frame;
			m_render.bitmapData = animationFrame.frameData;
			m_render.x = animationFrame.x;
			m_render.y = animationFrame.y;
		}

		public function setAvatarId(avatarId : String) : void
		{
			m_lazyAvatar.setAvatarId(avatarId);
			if (!m_lazyAvatar.isChange)
				return;
			m_lazyAvatar.addNotifyCompleted(onLoadAvatarComplete);
			m_lazyAvatar.loadResource();
		}

		private function onLoadAvatarComplete(avatar : SAvatar) : void
		{
			m_avatar = avatar;
			m_avatar.gotoAnimation(SActionType.IDLE, 0, SDirection.SOUTH, 0, 0);
		}

		override public function destroy() : void
		{
			super.destroy();
			m_lazyAvatar && m_lazyAvatar.dispose();
			m_lazyAvatar = null;
			animationFrame = null;
			m_avatar = null;
		}
	}
}