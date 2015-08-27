package hy.game.aEffect
{
	import flash.system.System;
	import flash.utils.ByteArray;
	
	import hy.game.cfg.Config;
	import hy.game.data.SObject;
	import hy.game.manager.SReferenceManager;
	import hy.game.resources.SResource;

	public class SEffectResource extends SObject
	{
		/**
		 * 加载成功后回调
		 */
		protected var mNotifyCompleteds : Vector.<Function>;
		private var mPriority : int;
		private var mChange : Boolean;
		private var mEffectId : String;
		private var mEffect : SEffect;

		public function SEffectResource()
		{
			super();

		}

		public function setEffectId(id : String) : void
		{
			if (mEffectId == id)
				return;
			mEffectId = id;
			mChange = true;
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
			if (!mEffectId || !mChange)
				return;
			mChange = false;
			var effectDescription : SEffectDescription = SEffectDescription.getEffectDescription(mEffectId);
			if (effectDescription)
			{
				onLoadComplete(null);
				return;
			}
			
			var resource : SResource = SReferenceManager.getInstance().createResource(mEffectId + (Config.supportDirectX ? "_atf" : ""));
			if (resource)
			{
				if (resource.isLoading)
					resource.addNotifyCompleted(onLoadComplete);
				if (resource.isLoaded)
					onLoadComplete(resource);
				else
					resource.setPriority(mPriority).addNotifyCompleted(onLoadComplete).load();
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
				notify(mEffect);
			}
			mNotifyCompleteds.length = 0;
		}

		private function onLoadComplete(res : SResource) : void
		{
			var effectDescription : SEffectDescription = createEffectDescription(res, mEffectId);
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
			mEffect && mEffect.dispose();
			mEffect = new SEffect();
			mEffect.initEffect(effectDescription);
			mEffect.effectAnimationLibrary = animations;
		}

		/**
		 * 调用此方向可以清除构建器，如果正在构建中，则会取消操作
		 */
		public function destroy() : void
		{
			if (mEffect)
			{
				mEffect.dispose();
				mEffect = null;
			}
			mNotifyCompleteds = null;
		}
	}
}