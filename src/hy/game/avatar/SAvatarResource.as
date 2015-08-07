package hy.game.avatar
{
	import flash.system.System;
	import flash.utils.ByteArray;

	import hy.game.data.SObject;
	import hy.game.manager.SReferenceManager;
	import hy.game.resources.SResource;
	import hy.rpg.enum.EnumDirection;



	public class SAvatarResource extends SObject
	{
		private var m_avatar : SAvatar;
		private var m_change : Boolean;
		private var m_avatarId : String;
		private var m_priority : int;
		/**
		 * 加载成功后回调
		 */
		protected var m_notifyCompleteds : Vector.<Function>;

		public function SAvatarResource(avatar : SAvatar)
		{
			super();
			m_avatar = avatar;
			if (m_avatar == null)
				error(this, "avatar is null!");
		}

		/**
		 * 加载的优先级别
		 * @param value
		 *
		 */
		public function set priority(value : int) : void
		{
			m_priority = value;
		}

		/**
		 * 设置需要加载avatarId
		 * @param id
		 *
		 */
		public function setAvatarId(id : String) : void
		{
			if (m_avatarId == id)
				return;
			m_avatarId = id;
			m_change = true;
		}

		/**
		 * avatar是否有改变
		 * @return
		 *
		 */
		public function get isChange() : Boolean
		{
			return m_change;
		}

		public function loadResource() : void
		{
			if (!m_avatarId || !m_change)
				return;
			m_change = false;

			var avatarDescription : SAvatarDescription = SAvatarManager.getInstance().getAvatarDescription(m_avatarId);
			if (avatarDescription)
			{
				createAvatar(avatarDescription);
				invokeNotifyByArray();
				return;
			}
			var resource : SResource = SReferenceManager.getInstance().createResource(m_avatarId);

			if (resource)
			{
				if (resource.isLoading)
					resource.addNotifyCompleted(notifyAvatarBuildCompleted);
				if (resource.isLoaded)
					notifyAvatarBuildCompleted(resource);
				else
					resource.setPriority(m_priority).addNotifyCompleted(notifyAvatarBuildCompleted).load();
			}
		}

		protected function notifyAvatarBuildCompleted(res : SResource) : void
		{
			var avatarDescription : SAvatarDescription = createAvatarDescription(res, m_avatarId);
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
			if (!m_notifyCompleteds)
				m_notifyCompleteds = new Vector.<Function>();
			if (m_notifyCompleteds.indexOf(notifyFunction) == -1)
				m_notifyCompleteds.push(notifyFunction);
			return this;
		}

		private function invokeNotifyByArray() : void
		{
			if (!m_notifyCompleteds)
				return;
			for each (var notify : Function in m_notifyCompleteds)
			{
				notify();
			}
			m_avatar = null;
			m_notifyCompleteds.length = 0;
		}

		/**
		 * 根据描述创建avatar
		 * @param avatarDesc
		 *
		 */
		private function createAvatar(avatarDesc : SAvatarDescription) : void
		{
			//已经销毁则不处理，直接返回
			if (!m_notifyCompleteds)
				return;
			var animations : SAvatarAnimationLibrary = SReferenceManager.getInstance().createAvatarCollection(m_priority, "whole1", avatarDesc);
			m_avatar.dirMode = EnumDirection.checkDirsDirMode(avatarDesc.directions);
			m_avatar.animationsByParts = animations;
		}

		public function get avatarId() : String
		{
			return m_avatarId;
		}

		public function dispose() : void
		{
			m_avatar = null;
			m_notifyCompleteds = null;
		}
	}
}