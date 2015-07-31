package hy.game.aEffect
{
	import flash.system.System;
	import flash.utils.ByteArray;
	
	import hy.game.data.SObject;
	import hy.game.manager.SReferenceManager;
	import hy.game.resources.SResource;

	public class SEffectResource extends SObject
	{
		/**
		 * 加载成功后回调
		 */
		protected var m_notifyCompleteds : Vector.<Function>;
		private var m_priority : int;
		private var m_change : Boolean;
		private var m_effectId : String;
		private var m_effect : SEffect;

		public function SEffectResource()
		{
			super();

		}

		public function setEffectId(id : String) : void
		{
			if (m_effectId == id)
				return;
			m_effectId = id;
			m_change = true;
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
			if (!m_effectId || !m_change)
				return;
			m_change = false;
			var effectDescription : SEffectDescription = SEffectDescription.getEffectDescription(m_effectId);
			if (effectDescription)
			{
				invokeNotifyByArray();
				return;
			}
			var resource : SResource = SReferenceManager.getInstance().createResource(m_effectId);
			if (resource)
			{
				if (resource.isLoading)
					resource.addNotifyCompleted(onLoadComplete);
				if (resource.isLoaded)
					onLoadComplete(resource);
				else
					resource.priority(m_priority).addNotifyCompleted(onLoadComplete).load();
			}
		}

		/**
		 * 加载完成通知处理函数
		 * @param notifyFunction
		 * @return
		 *
		 */
		public function addNotifyCompleted(notifyFunction : Function) : SEffectResource
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
				notify(m_effect);
			}
			m_notifyCompleteds.length = 0;
		}

		private function onLoadComplete(res : SResource) : void
		{
			var effectDescription : SEffectDescription = createEffectDescription(res, m_effectId);
			if (effectDescription)
			{
				createEffect(effectDescription);
				invokeNotifyByArray();
			}
		}

		private function createEffectDescription(res : SResource, effectId : String) : SEffectDescription
		{
			var effectDescription : SEffectDescription = SEffectDescription.getEffectDescription(effectId);
			if (!effectDescription)
			{
				var bytes : ByteArray = res.getBinary();
				if (bytes)
				{
					bytes.position = 0;
					var configData : XML = XML(bytes.readUTFBytes(bytes.bytesAvailable));
					SEffectDescription.addEffectDescription(effectId, configData, configData.@version);
					effectDescription = SEffectDescription.getEffectDescription(effectId);
					System.disposeXML(configData);
				}
			}
			return effectDescription;
		}

		/**
		 * 根据描述创建effect
		 * @param effectDesc
		 *
		 */
		private function createEffect(effectDescription : SEffectDescription) : void
		{
			//建立每个独立部件的动画数据
			var animations : SEffectAnimationLibrary = SReferenceManager.getInstance().createEffectCollection(effectDescription, true);
			m_effect && m_effect.dispose();
			m_effect = new SEffect(effectDescription);
			m_effect.animationsByParts = animations;
		}

		/**
		 * 调用此方向可以清除构建器，如果正在构建中，则会取消操作
		 */
		public function destroy() : void
		{
			if(m_effect)
			{
				m_effect.dispose();
				m_effect=null;
			}
			m_notifyCompleteds = null;
		}
	}
}