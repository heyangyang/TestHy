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
		private static var sMouseOverGlowFilters : Array = [new GlowFilter(0xffff00, 1, 6, 6, 2)];
		private static var sNullFilters : Array = [];

		private static var sDirectMouseOverGlowFilters : Vector.<Number> = new <Number>[1.4, 1.4, 1.4, 1.0, 1.4, 1.4, 1.4, 1.0, 1.4, 1.4, 1.4, 1.0, 1.4, 1.4, 1.4, 1.0];
		private static var sDirectNullFilters : Vector.<Number> = null;

		private static var sCurrFilters : *;
		private static var sCurrNull : *;

		public static function init(direct : Boolean) : void
		{
			sCurrFilters = direct ? sDirectMouseOverGlowFilters : sMouseOverGlowFilters;
			sCurrNull = direct ? sDirectNullFilters : sNullFilters;
		}

		protected var mTransform : STransform;
		private var mIsMouseOver : Boolean;
		private var mAvatar : SAvatarComponent;
		private var mWing : SAvatarComponent;
		private var mMount : SAvatarComponent;

		public function SCollisionComponent(type : * = null)
		{
			super(type);
		}

		override public function notifyAdded() : void
		{
			mTransform = mOwner.transform;
			mIsMouseOver = mTransform.isMouseOver;
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
			return mTransform.contains(mouseX, mouseY);
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
			if (mAvatar == null)
			{
				mAvatar = mOwner.getComponentByType(SAvatarComponent) as SAvatarComponent;
				mWing = mOwner.getComponentByType(ComponentWing) as SAvatarComponent;
				mMount = mOwner.getComponentByType(ComponentMount) as SAvatarComponent;
			}
			mouseX -= mTransform.x;
			mouseY -= mTransform.y;
			if (mAvatar && mAvatar.isRolePickable(mouseX, mouseY))
				return true;
			if (mWing && mWing.isRolePickable(mouseX, mouseY))
				return true;
			if (mMount && mMount.isRolePickable(mouseX, mouseY))
				return true;
			return false;
		}

		public function set isMouseOver(value : Boolean) : void
		{
			if (mIsMouseOver == value)
				return;
			mIsMouseOver = value;
			mTransform.isMouseOver = value;
			mTransform.filters = value ? sCurrFilters : sCurrNull;
		}

		public function get index() : int
		{
			return mTransform.y;
		}
	}
}