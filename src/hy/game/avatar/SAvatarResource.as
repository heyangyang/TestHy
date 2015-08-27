package hy.game.avatar
{
	import flash.system.System;
	import flash.utils.ByteArray;

	import hy.game.cfg.Config;
	import hy.game.data.SObject;
	import hy.game.manager.SReferenceManager;
	import hy.game.resources.SResource;
	import hy.rpg.enum.EnumDirection;



	public class SAvatarResource extends SObject
	{
		private var mAvatar : SAvatar;
		private var mChange : Boolean;
		private var mAvatarId : String;
		private var mPriority : int;
		/**
		 * 加载成功后回调
		 */
		protected var mNotifyCompleteds : Vector.<Function>;

		public function SAvatarResource(avatar : SAvatar)
		{
			super();
			mAvatar = avatar;
			if (mAvatar == null)
				error(this, "avatar is null!");
		}

		/**
		 * 加载的优先级别
		 * @param value
		 *
		 */
		public function set priority(value : int) : void
		{
			mPriority = value;
		}

		/**
		 * 设置需要加载avatarId
		 * @param id
		 *
		 */
		public function setAvatarId(id : String) : void
		{
			if (mAvatarId == id)
				return;
			mAvatarId = id;
			mChange = true;
		}

		/**
		 * avatar是否有改变
		 * @return
		 *
		 */
		public function get isChange() : Boolean
		{
			return mChange;
		}

		public function loadResource() : void
		{
			if (!mAvatarId || !mChange)
				return;
			mChange = false;

			var avatarDescription : SAvatarDescription = SAvatarManager.getInstance().getAvatarDescription(mAvatarId);
			if (avatarDescription)
			{
				createAvatar(avatarDescription);
				invokeNotifyByArray();
				return;
			}

			var resource : SResource = SReferenceManager.getInstance().createResource(mAvatarId + (Config.supportDirectX ? "_atf" : ""));

			if (resource)
			{
				if (resource.isLoading)
					resource.addNotifyCompleted(notifyAvatarBuildCompleted);
				if (resource.isLoaded)
					notifyAvatarBuildCompleted(resource);
				else
					resource.setPriority(mPriority).addNotifyCompleted(notifyAvatarBuildCompleted).load();
			}
		}

		protected function notifyAvatarBuildCompleted(res : SResource) : void
		{
			var avatarDescription : SAvatarDescription = createAvatarDescription(res, mAvatarId);
			if (avatarDescription)
			{
				createAvatar(avatarDescription);
				invokeNotifyByArray();
			}
		}

		private function createAvatarDescription(res : SResource, avatarId : String) : SAvatarDescription
		{
			var avatarDescription : SAvatarDescription = SAvatarManager.getInstance().getAvatarDescription(avatarId);
			if (!avatarDescription)
			{
				var bytes : ByteArray = res.getBinary();
				if (bytes)
				{
					var configData : XML = XML(bytes.readUTFBytes(bytes.bytesAvailable));
					avatarDescription = SAvatarManager.getInstance().addAvatarDescription(avatarId, configData, configData.@version);
					//清理XML
					System.disposeXML(configData);
				}
			}
			return avatarDescription;
		}

		/**
		 * 加载完成通知处理函数
		 * @param notifyFunction
		 * @return
		 *
		 */
		public function addNotifyCompleted(notifyFunction : Function) : SAvatarResource
		{
			if (notifyFunction == null)
				return this;
			if (!mNotifyCompleteds)
				mNotifyCompleteds = new Vector.<Function>();
			if (mNotifyCompleteds.indexOf(notifyFunction) == -1)
				mNotifyCompleteds.push(notifyFunction);
			return this;
		}

		private function invokeNotifyByArray() : void
		{
			if (!mNotifyCompleteds)
				return;
			for each (var notify : Function in mNotifyCompleteds)
			{
				notify();
			}
			mAvatar = null;
			mNotifyCompleteds.length = 0;
		}

		/**
		 * 根据描述创建avatar
		 * @param avatarDesc
		 *
		 */
		private function createAvatar(avatarDesc : SAvatarDescription) : void
		{
			//已经销毁则不处理，直接返回
			if (!mNotifyCompleteds)
				return;
			var animations : SAvatarAnimationLibrary = SReferenceManager.getInstance().createAvatarCollection(mPriority, "whole1", avatarDesc);
			mAvatar.dirMode = EnumDirection.checkDirsDirMode(avatarDesc.directions);
			mAvatar.animationsByParts = animations;
		}

		public function get avatarId() : String
		{
			return mAvatarId;
		}

		public function dispose() : void
		{
			mAvatar = null;
			mNotifyCompleteds = null;
		}
	}
}