package hy.game.components
{
	import hy.game.animation.SAnimationFrame;
	import hy.game.avatar.SActionType;
	import hy.game.avatar.SAvatar;
	import hy.game.avatar.SAvatarResource;
	import hy.game.core.STime;
	import hy.game.manager.SLayerManager;
	import hy.rpg.components.data.DataComponent;
	import hy.rpg.enum.EnumLoadPriority;
	import hy.rpg.enum.EnumRenderLayer;

	/**
	 * 人物模型组件
	 * @author hyy
	 *
	 */
	public class SAvatarComponent extends SRenderComponent
	{
		/**
		 * 默认模型
		 */
		public static var sDefaultAvatar : SAvatar;

		protected var mResource : SAvatarResource;
		protected var mAvatar : SAvatar;
		protected var mFrame : SAnimationFrame;
		private var tFrame : SAnimationFrame;
		private var needReversal : Boolean;
		protected var mData : DataComponent;

		private var mUseCenterOffsetY : Boolean;
		private var mIsUseFilters : Boolean;
		private var mUseDefaultAvatar : Boolean;
		private var mLastFrameIndex : int;
		private var mAutoUpdateFrame : Boolean;

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
			mAvatar = new SAvatar();
			mResource = new SAvatarResource(mAvatar);
		}

		override public function notifyAdded() : void
		{
			super.notifyAdded();
			mLayerType = SLayerManager.LAYER_ENTITY;
			mResource.priority = EnumLoadPriority.ROLE;
			mRender.layer = EnumRenderLayer.BODY;
			needReversal = false;
			mLastFrameIndex = -1;
		}

		/**
		 * 继承的子类，必须调用该类方法
		 *
		 */
		override protected function onStart() : void
		{
			super.onStart();
			mData = mOwner.getComponentByType(DataComponent) as DataComponent;
			mTransform.addAavatarChange(changeAvatarAction);
			mTransform.addColorTransformChange(changeColorTransform);
			mTransform.addPositionChange(updatePosition);
			if (mUseDefaultAvatar)
			{
				mAvatar.dirMode = sDefaultAvatar.dirMode;
				//自增下，以免被垃圾回收
				sDefaultAvatar.animationsByParts.retain();
				mAvatar.animationsByParts = sDefaultAvatar.animationsByParts;
				onLoadAvatarComplete();
			}
			setAvatarId(mData.avatarId);
		}

		override public function notifyRemoved() : void
		{
			super.notifyRemoved();
			tFrame = mFrame = null;
			mAvatar = null;
			mData = null;
		}

		override public function update() : void
		{
			//加载资源
			if (mResource.isChange)
			{
				mResource.addNotifyCompleted(onLoadAvatarComplete);
				mResource.loadResource();
			}

			if (mAutoUpdateFrame)
			{
				tFrame = mAvatar.gotoNextFrame(STime.deltaTime);
				mTransform.frameIndex = mAvatar.curFrameIndex;
			}
			else if (mTransform.frameIndex != mLastFrameIndex)
			{
				mLastFrameIndex = mTransform.frameIndex;
				tFrame = mAvatar.gotoFrame(mTransform.frameIndex);
			}

			//使用默认模型
			if (mUseDefaultAvatar && (!tFrame || !tFrame.frameData))
			{
				tFrame = sDefaultAvatar.gotoAnimation(mTransform.action, mTransform.dir, mAvatar.curFrameIndex, 0);
			}

			updateAnimationFrame();
			updatePosition();
		}

		/**
		 * 更新动画帧
		 *
		 */
		protected function updateAnimationFrame() : void
		{
			//图片为空
			if (!tFrame || !tFrame.frameData)
			{
				mRender.data = null;
				return;
			}
			//相同图片
			if (tFrame == mFrame)
				return;
			mFrame = tFrame;
			mTransform.rectangle.contains(mFrame.rect);
			if (needReversal != mFrame.needReversal)
			{
				needReversal = mFrame.needReversal;
				mRender.scaleX = needReversal ? -1 : 1;
			}
			mFrame.needReversal && mFrame.reverseData();
			mRender.data = mFrame.frameData;
		}

		/**
		 * 位置更新
		 *
		 */
		protected function updatePosition() : void
		{
			if (!mFrame)
				return;
			mRender.x = mTransform.screenX + mFrame.x;
			if (mUseCenterOffsetY)
				mRender.y = mTransform.screenY + mFrame.y + mTransform.centerOffsetY;
			else
				mRender.y = mTransform.screenY + mFrame.y;
			mRender.depth = mTransform.screenY;
		}

		/**
		 * 转换动作的一些操作
		 *
		 */
		protected function changeAvatarAction() : void
		{
			mTransform.height = mTransform.height - (mTransform.isRide ? 30 : 0);

			if (mTransform.isRide)
				mAvatar.gotoAnimation(SActionType.SIT, mTransform.dir, 0, 0);
			else
				mAvatar.gotoAnimation(mTransform.action, mTransform.dir, 0, 0);
		}

		/**
		 * 滤镜变换
		 *
		 */
		protected function changeColorTransform() : void
		{
			mRender.colorFilter = mTransform.filters;
		}

		public function setAvatarId(avatarId : String) : void
		{
			mResource.setAvatarId(avatarId);
		}

		protected function onLoadAvatarComplete() : void
		{
			mTransform.width = mAvatar.width;
			mTransform.height = mAvatar.height;
			changeAvatarAction();
		}

		public function isRolePickable(mouseX : int, mouseY : int) : Boolean
		{
			if (mFrame && mFrame.frameData)
			{
				mouseX -= mFrame.x;
				mouseY -= mFrame.y;
				//反转的时候，需要把坐标反转
				if (mFrame.needReversal)
					mouseX = -mouseX;
				if (mFrame.frameData.getPixel(mouseX, mouseY) != 0)
				{
					return true;
				}
			}
			return false;
		}

		/**
		 * 是否使用默认模型
		 * @param value
		 *
		 */
		public function set useDefaultAvatar(value : Boolean) : void
		{
			mUseDefaultAvatar = value;
		}

		/**
		 * 是否使用滤镜
		 */
		public function set isUseFilters(value : Boolean) : void
		{
			mIsUseFilters = value;
		}

		/**
		 * 是否使用人物中心Y便偏移点
		 */
		public function set useCenterOffsetY(value : Boolean) : void
		{
			mUseCenterOffsetY = value;
		}

		/**
		 * 自动更新动画
		 * @param value
		 *
		 */
		public function set autoUpdateFrame(value : Boolean) : void
		{
			mAutoUpdateFrame = value;
		}

		override public function dispose() : void
		{
			super.dispose();
			mResource && mResource.dispose();
			mResource = null;
		}

	}
}