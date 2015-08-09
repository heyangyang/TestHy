package hy.game.components
{
	import flash.filters.GlowFilter;

	import hy.game.core.Component;
	import hy.game.data.STransform;
	import hy.game.update.SMouseUpdateMangaer;
	import hy.rpg.components.ComponentMount;
	import hy.rpg.components.ComponentWing;

	/**
	 * 鼠标碰撞组件
	 * @author hyy
	 *
	 */
	public class SCollisionComponent extends Component
	{
		private static var mouseOverGlowFilters : Array = [new GlowFilter(0xffff00, 1, 6, 6, 2)];
		private static var nullFilters : Array = [];

		protected var m_transform : STransform;
		private var m_isMouseOver : Boolean;
		private var m_avatar : SAvatarComponent;
		private var m_wing : SAvatarComponent;
		private var m_mount : SAvatarComponent;

		public function SCollisionComponent(type : * = null)
		{
			super(type);
		}

		override public function notifyAdded() : void
		{
			m_transform = m_owner.transform;
			m_isMouseOver = m_transform.isMouseOver;
			SMouseUpdateMangaer.addComponent(this);
		}

		override public function notifyRemoved() : void
		{
			SMouseUpdateMangaer.removeComponent(this);
		}

		/**
		 * 检测鼠标是否在矩阵内
		 * @param mouseX
		 * @param mouseY
		 * @return
		 *
		 */
		public function checkIsMouseIn(mouseX : int, mouseY : int) : Boolean
		{
			return m_transform.contains(mouseX, mouseY);
		}

		/**
		 * 像素级检测 
		 * @param mouseX
		 * @param mouseY
		 * @return 
		 * 
		 */
		public function checkPixelIn(mouseX : int, mouseY : int) : Boolean
		{
			if (m_avatar == null)
			{
				m_avatar = m_owner.getComponentByType(SAvatarComponent) as SAvatarComponent;
				m_wing = m_owner.getComponentByType(ComponentWing) as SAvatarComponent;
				m_mount = m_owner.getComponentByType(ComponentMount) as SAvatarComponent;
			}
			mouseX -= m_transform.x;
			mouseY -= m_transform.y;
			if (m_avatar && m_avatar.isRolePickable(mouseX, mouseY))
				return true;
			if (m_wing && m_wing.isRolePickable(mouseX, mouseY))
				return true;
			if (m_mount && m_mount.isRolePickable(mouseX, mouseY))
				return true;
			return false;
		}

		public function set isMouseOver(value : Boolean) : void
		{
			if (m_isMouseOver == value)
				return;
			m_isMouseOver = value;
			m_transform.isMouseOver = value;
			m_transform.filters = value ? mouseOverGlowFilters : nullFilters;
		}

		public function get index() : int
		{
			return m_owner.render.index;
		}
	}
}