package hy.game.components
{
	import hy.game.animation.SAnimationFrame;
	import hy.game.avatar.SActionType;
	import hy.game.avatar.SAvatar;
	import hy.game.avatar.SAvatarResource;
	import hy.game.core.STime;
	import hy.game.enum.EnumPriority;
	import hy.rpg.components.data.DataComponent;
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
		protected var m_frame : SAnimationFrame;
		protected var tmp_frame : SAnimationFrame;
		protected var m_data : DataComponent;
		protected var m_dir : int;
		protected var m_action : int;
		protected var m_height : int;
		protected var m_isRide : Boolean;
		protected var needReversal : Boolean;
		protected var m_useCenterOffsetY : Boolean;

		public function SAvatarComponent(type : * = null)
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
			m_lazyAvatar = new SAvatarResource();
			m_lazyAvatar.defaultAvatar = true;
		}

		/**
		 * 继承的子类，必须调用该类方法
		 *
		 */
		override protected function onStart() : void
		{
			super.onStart();
			m_data = m_owner.getComponentByType(DataComponent) as DataComponent;
			setAvatarId(m_data.avatarId);
		}

		override public function notifyAdded() : void
		{
			super.notifyAdded();
			m_lazyAvatar.priority = EnumLoadPriority.ROLE;
			registerd(EnumPriority.PRIORITY_9);
			m_dir = m_action = -1;
			m_useCenterOffsetY = true;
			needReversal = false;
			m_isRide = false;
		}

		override public function notifyRemoved() : void
		{
			super.notifyRemoved();
			tmp_frame = m_frame = null;
			m_avatar = null;
			m_data = null;
		}

		override public function update() : void
		{
			if (m_lazyAvatar.isChange)
			{
				m_lazyAvatar.addNotifyCompleted(onLoadAvatarComplete);
				m_lazyAvatar.loadResource();
			}
			if (!m_avatar)
			{
				m_render.bitmapData = null;
				return;
			}
			if (m_dir != m_transform.dir || m_action != m_data.action || m_isRide != m_data.isRide)
			{
				m_dir = m_transform.dir;
				m_action = m_data.action;
				if (m_isRide != m_data.isRide)
				{
					m_isRide = m_data.isRide;
					if (m_height > 0)
						m_transform.height = m_height - (m_isRide ? 20 : 0);
				}
				changeAnimation();
			}
			else
				tmp_frame = m_avatar.gotoNextFrame(STime.deltaTime);
			if (!tmp_frame || !tmp_frame.frameData)
			{
				m_render.bitmapData = null;
				return;
			}
			if (tmp_frame == m_frame)
				return;
			m_frame = tmp_frame;
			m_transform.rectangle.contains(m_frame.rect);
			if (needReversal != m_frame.needReversal)
			{
				needReversal = m_frame.needReversal;
				m_render.scaleX = needReversal ? -1 : 1;
			}
			m_frame.needReversal && m_frame.reverseData();
			m_render.bitmapData = m_frame.frameData;
			m_render.x = m_frame.x;
			if (m_useCenterOffsetY)
				m_render.y = m_frame.y + m_transform.centerOffsetY;
			else
				m_render.y = m_frame.y;
		}

		/**
		 * 转换动作的一些操作
		 *
		 */
		protected function changeAnimation() : void
		{
			if (m_data.isRide)
				tmp_frame = m_avatar.gotoAnimation(SActionType.SIT, 0, m_dir, 0, 0);
			else
				tmp_frame = m_avatar.gotoAnimation(m_action, 0, m_dir, 0, 0);
		}

		public function setAvatarId(avatarId : String) : void
		{
			m_lazyAvatar.setAvatarId(avatarId);
		}

		protected function onLoadAvatarComplete(avatar : SAvatar) : void
		{
			m_avatar = avatar;
			m_owner.transform.width = avatar.width;
			m_height = m_owner.transform.height = avatar.height;
			m_dir = m_action = -1;
			m_isRide = !m_data.isRide;
		}

		override public function destroy() : void
		{
			super.destroy();
			m_lazyAvatar && m_lazyAvatar.dispose();
			m_lazyAvatar = null;
		}
	}
}