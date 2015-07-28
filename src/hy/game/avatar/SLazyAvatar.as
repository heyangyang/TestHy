package hy.game.avatar
{
	

	public class SLazyAvatar
	{
		protected var resource : SAvatarResource;
		protected var oldPart : String;
		public var isChangeAvatar : Boolean;
		public var avatarId : String;
		public var avatar : SAvatar;
		public var notifyComplete : Function;
		private var isShowModelData : Boolean;
		private var priority : int;

		public function SLazyAvatar(isShowModelData : Boolean, priority : int)
		{
			super();
			this.priority = priority;
			this.isShowModelData = isShowModelData;
		}

		public function modelStatus(value : Boolean) : void
		{
			isShowModelData = value;
		}

		public function setAvatarId(id : String) : void
		{
			if (avatarId == id)
				return;
			avatarId = id;
			isChangeAvatar = true;
		}

		public function loadResource(part : String = "whole1") : void
		{
			if (!avatarId || !isChangeAvatar)
				return;
			isChangeAvatar = false;
			//资源小于5向
			if (resource)
				resource.dispose();
			oldPart = part;
			resource = new SAvatarResource(avatarId, priority, isShowModelData);
			resource.onComplete(notifyAvatarBuildCompleted);
			resource.load(part, priority, true);
		} 

		protected function notifyAvatarBuildCompleted(avatarResource : SAvatarResource) : void
		{
			avatar = avatarResource.avatar;
			if (notifyComplete != null)
				notifyComplete();
		}

		public function destroy() : void
		{
			if (resource)
				resource.dispose();
			avatar = null;
			notifyComplete = null;
		}
	}
}