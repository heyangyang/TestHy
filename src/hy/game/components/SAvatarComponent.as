package hy.game.components
{
	import hy.game.animation.SAnimationFrame;
	import hy.game.avatar.SActionType;
	import hy.game.avatar.SAvatar;
	import hy.game.avatar.SAvatarResource;
	import hy.game.core.STime;
	import hy.rpg.components.data.DataComponent;
	import hy.rpg.enum.EnumLoadPriority;

	/**
	 * 人物模型组件
	 * @author hyy
	 *
	 */
	public class SAvatarComponent extends SRenderComponent
	{
		public static var defaultAvatar : SAvatar;
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
		/**
		 * 是否使用人物中心Y便宜点
		 */
		protected var m_useCenterOffsetY : Boolean;
		/**
		 * 是否使用滤镜
		 */
		protected var m_isUseFilters : Boolean;
		/**
		 * 当前滤镜
		 */
		protected var m_filters : Array;
		/**
		 * 是否使用默认模型
		 */
		protected var m_useDefaultAvatar : Boolean;

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
		}

		override public function notifyAdded() : void
		{
			super.notifyAdded();
			m_lazyAvatar.priority = EnumLoadPriority.ROLE;
			m_dir = m_action = -1;
			m_useCenterOffsetY = true;
			needReversal = false;
			m_isRide = false;
			m_isUseFilters = true;
			m_useDefaultAvatar = true;
		}

		/**
		 * 继承的子类，必须调用该类方法
		 *
		 */
		override protected function onStart() : void
		{
			super.onStart();
			m_data = m_owner.getComponentByType(DataComponent) as DataComponent;
//			if (m_useDefaultAvatar)
//				onLoadAvatarComplete(defaultAvatar);
//			m_useDefaultAvatar && onLoadAvatarComplete(defaultAvatar);
			setAvatarId(m_data.avatarId);
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

			if (m_isUseFilters && m_filters != m_transform.filters)
			{
				m_filters = m_transform.filters;
				m_render.filters = m_filters;
			}

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
			if (m_isRide)
				tmp_frame = m_avatar.gotoAnimation(SActionType.SIT, m_dir, 0, 0);
			else
				tmp_frame = m_avatar.gotoAnimation(m_action, m_dir, 0, 0);
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

		public function isRolePickable(mouseX : int, mouseY : int) : Boolean
		{
			if (m_frame && m_frame.frameData)
			{
				mouseX -= m_frame.x;
				mouseY -= m_frame.y;
				//反转的时候，需要把坐标反转
				if (m_frame.needReversal)
					mouseX = -mouseX;
				if (m_frame.frameData.getPixel(mouseX, mouseY) != 0)
				{
					return true;
				}
			}
			return false;
		}

		override public function destroy() : void
		{
			super.destroy();
			m_lazyAvatar && m_lazyAvatar.dispose();
			m_lazyAvatar = null;
		}
	}
}