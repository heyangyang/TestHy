package hy.game.avatar
{
	import hy.game.components.SRenderComponent;

	/**
	 * 人物模型组件
	 * @author hyy
	 *
	 */
	public class SAvatarComponent extends SRenderComponent
	{
		private var lazyAvatar : SLazyAvatar;

		public function SAvatarComponent(type : * = null)
		{
			super(type);
		}

		override public function notifyAdded() : void
		{
			super.notifyAdded();
			lazyAvatar = new SLazyAvatar(true, 0);
		}

		public function setAvatarId(avatarId : String) : void
		{
			lazyAvatar.setAvatarId(avatarId);
		}
	}
}