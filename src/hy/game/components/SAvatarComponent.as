package hy.game.components
{
	import hy.game.animation.SAnimationFrame;
	import hy.game.avatar.SActionType;
	import hy.game.avatar.SAvatar;
	import hy.game.avatar.SAvatarResource;
	import hy.game.core.STime;
	import hy.rpg.components.data.DataComponentRole;
	import hy.rpg.enum.EnumLoadPriority;

	/**
	 * 人物模型组件
	 * @author hyy
	 *
	 */
	public class SAvatarComponent extends SRenderComponent
	{
		protected var m_lazyAvatar : SAvatarResource;
		protected var m_avatar : SAvatar;
		private var m_frame : SAnimationFrame;
		protected var m_roleData : DataComponentRole;
		protected var m_dir : int;
		protected var m_action : int;

		public function SAvatarComponent(type : * = null)
		{
			super(type);
			m_lazyAvatar = new SAvatarResource();
			m_lazyAvatar.defaultAvatar = true;
			m_lazyAvatar.priority = EnumLoadPriority.ROLE;
		}

		override public function notifyAdded() : void
		{
			super.notifyAdded();
			m_roleData = m_owner.getComponentByType(DataComponentRole) as DataComponentRole;
			setAvatarId(m_roleData.avatarId);
			m_dir = m_action = -1;
		}

		override public function update() : void
		{
			if (m_lazyAvatar.isChange)
			{
				m_lazyAvatar.addNotifyCompleted(onLoadAvatarComplete);
				m_lazyAvatar.loadResource();
			}
			if (!m_avatar)
				return;
			if (m_dir != m_transform.dir || m_action != m_roleData.action)
			{
				m_dir = m_transform.dir;
				m_action = m_roleData.action
				m_avatar.gotoAnimation(m_action, 0, m_dir, 0, 0);
			}
			var frame : SAnimationFrame = m_avatar.gotoNextFrame(STime.deltaTime);
			if (!frame || frame == m_frame)
				return;
			m_frame = frame;
			m_render.bitmapData = m_frame.frameData;
			m_render.x = m_frame.x;
			m_render.y = m_frame.y;
		}

		public function setAvatarId(avatarId : String) : void
		{
			m_lazyAvatar.setAvatarId(avatarId);
		}

		protected function onLoadAvatarComplete(avatar : SAvatar) : void
		{
			m_avatar = avatar;
			m_owner.transform.width = avatar.width;
			m_owner.transform.height = avatar.height;
		}

		override public function destroy() : void
		{
			super.destroy();
			m_lazyAvatar && m_lazyAvatar.dispose();
			m_lazyAvatar = null;
			m_frame = null;
			m_avatar = null;
		}
	}
}