package hy.game.avatar
{
	import flash.system.System;
	import flash.utils.Dictionary;
	
	import hy.game.manager.SBaseManager;

	/**
	 *
	 * 动画管理器
	 *
	 */
	public class SAnimationManager extends SBaseManager
	{
		private static var _singleton : Boolean = true;
		private static var _instance : SAnimationManager;

		public var lazyAnimationInstanceCount : int;
		public var animationFrameInstanceCount : int;
		public var effectResourceInstanceCount : int;
		public var avatarResourceInstanceCount : int;

		public static function getInstance() : SAnimationManager
		{
			if (!_instance)
			{
				_singleton = false;
				_instance = new SAnimationManager();
				_singleton = true;
			}
			return _instance;
		}

		/**
		 * 合成Frame Dictionary
		 */
		private var _animationParser : SAnimationParser;

		public function SAnimationManager()
		{
			super();

			_animationParser = new SAnimationParser();

			lazyAnimationInstanceCount = 0;
			animationFrameInstanceCount = 0;
			effectResourceInstanceCount = 0;
			avatarResourceInstanceCount = 0;
		}

		/**
		 * 根据动画id得到动画描述符的映射
		 */
		private var _animationDescriptionById : Dictionary = new Dictionary(false);

		/**
		 * 获取动画描述
		 * @param id
		 * @return
		 *
		 */
		public function getAnimationDescription(id : String) : SAnimationDescription
		{
			if (!id)
				return null;
			id = id.toLowerCase();
			return _animationDescriptionById[id];
		}

		/**
		 * 添加批动画描述符
		 */
		public function addBatchAnimationDescription(xml : XML, width : int, height : int, version : String = null) : void
		{
			_animationParser.parseAnimations(xml, width, height, _animationDescriptionById, version);
			System.disposeXML(xml);
		}

		/**
		 * 创建动画
		 * animationId后面添加用来区分动画ID与资源ID，比如武器反转时需要ID与动画ID不同
		 */
		/**
		 * 创建Animation
		 * @param id 动画ID
		 * @animationId 资源ID，如果动画ID与资源ID可能不同，则传入参数，如果为空则使用id
		 * @param otherIds 其他方向ID
		 * @param saveAnimation 是否将动画保存
		 * @param priority 下载优先级
		 * @param needReversal 是否要反转
		 */
		public function createAnimation(resId : String, animationId : String = null, needReversal : Boolean = false) : SLazyAnimation
		{
			var animation : SLazyAnimation;
			animationId = animationId || resId;
			var desc : SAnimationDescription = _animationDescriptionById[animationId];

			if (desc)
			{
				animation = new SLazyAnimation(resId, desc, needReversal);
				return animation;
			}
			else
			{
				//(this, "动画资源" + resId + "对应的动画描述" + animationId + "不存在！");
			}
			return null;
		}
	}
}