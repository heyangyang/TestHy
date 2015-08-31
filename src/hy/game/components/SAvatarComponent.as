package hy.game.components
{
	import hy.game.animation.SAnimationFrame;
	import hy.game.avatar.SActionType;
	import hy.game.avatar.SAvatar;
	import hy.game.avatar.SAvatarResource;
	import hy.game.core.STime;
	import hy.game.manager.SLayerManager;
	import hy.game.render.SRender;
	import hy.rpg.components.data.DataComponent;
	import hy.rpg.enum.EnumLoadPriority;

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
		public static var default_avatar : SAvatar;

		protected var mResource : SAvatarResource;
		protected var mAvatar : SAvatar;
		protected var mFrame : SAnimationFrame;
		protected var tmp_frame : SAnimationFrame;
		protected var mData : DataComponent;
		protected var mDir : int;
		protected var mAction : int;
		protected var mHeight : int;
		protected var mIsRide : Boolean;
		protected var needReversal : Boolean;
		/**
		 * 是否使用人物中心Y便宜点
		 */
		protected var mUseCenterOffsetY : Boolean;
		/**
		 * 是否使用滤镜
		 */
		protected var mIsUseFilters : Boolean;
		/**
		 * 当前滤镜
		 */
		protected var mFilters : Array;
		/**
		 * 是否使用默认模型
		 */
		protected var mUseDefaultAvatar : Boolean;

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
			mRender.dropShadow = true;
			mAvatar = new SAvatar();
			mResource = new SAvatarResource(mAvatar);
		}

		override public function notifyAdded() : void
		{
			super.notifyAdded();
			mResource.priority = EnumLoadPriority.ROLE;
			mDir = mAction = -1;
			mUseCenterOffsetY = true;
			needReversal = false;
			mIsRide = false;
			mIsUseFilters = true;
			mUseDefaultAvatar = true;
		}

		/**
		 * 继承的子类，必须调用该类方法
		 *
		 */
		override protected function onStart() : void
		{
			super.onStart();
			mData = mOwner.getComponentByType(DataComponent) as DataComponent;
			if (mUseDefaultAvatar)
			{
				mAvatar.dirMode = default_avatar.dirMode;
				//自增下，以免被垃圾回收
				default_avatar.animationsByParts.retain();
				mAvatar.animationsByParts = default_avatar.animationsByParts;
				onLoadAvatarComplete();
			}
			setAvatarId(mData.avatarId);
		}

		override public function notifyRemoved() : void
		{
			super.notifyRemoved();
			tmp_frame = mFrame = null;
			mAvatar = null;
			mData = null;
		}
		override public function update() : void
		{
			if (mResource.isChange)
			{
				mResource.addNotifyCompleted(onLoadAvatarComplete);
				mResource.loadResource();
			}
			if (mDir != mTransform.dir || mAction != mData.action || mIsRide != mData.isRide)
			{
				mDir = mTransform.dir;
				mAction = mData.action;
				if (mIsRide != mData.isRide)
				{
					mIsRide = mData.isRide;
					if (mHeight > 0)
						mTransform.height = mHeight - (mIsRide ? 30 : 0);
				}
				changeAnimation();
			}
			else
				tmp_frame = mAvatar.gotoNextFrame(STime.deltaTime);

			if (mIsUseFilters && mFilters != mTransform.filters)
			{
				mFilters = mTransform.filters;
				mRender.filters = mFilters;
			}

			if (mUseDefaultAvatar && (!tmp_frame || !tmp_frame.frameData))
			{
				tmp_frame = default_avatar.gotoAnimation(mAction, mDir, mAvatar.curFrameIndex, 0);
			}
			if (!tmp_frame || !tmp_frame.frameData)
			{
				mRender.bitmapData = null;
				return;
			}
			if (tmp_frame == mFrame)
				return;
			mFrame = tmp_frame;
			mTransform.rectangle.contains(mFrame.rect);
			if (needReversal != mFrame.needReversal)
			{
				needReversal = mFrame.needReversal;
				mRender.scaleX = needReversal ? -1 : 1;
			}
			mFrame.needReversal && mFrame.reverseData();
			mRender.bitmapData = mFrame.frameData;
			mRender.x = mFrame.x;
			if (mUseCenterOffsetY)
				mRender.y = mFrame.y + mTransform.centerOffsetY;
			else
				mRender.y = mFrame.y;
		}

		/**
		 * 转换动作的一些操作
		 *
		 */
		protected function changeAnimation() : void
		{
			if (mIsRide)
				tmp_frame = mAvatar.gotoAnimation(SActionType.SIT, mDir, 0, 0);
			else
				tmp_frame = mAvatar.gotoAnimation(mAction, mDir, 0, 0);
		}

		public function setAvatarId(avatarId : String) : void
		{
			mResource.setAvatarId(avatarId);
		}

		protected function onLoadAvatarComplete() : void
		{
			mOwner.transform.width = mAvatar.width;
			mHeight = mOwner.transform.height = mAvatar.height;
			mDir = mAction = -1;
			mIsRide = !mData.isRide;
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
		 * 不添加到父类，直接添加到name层
		 * @param render
		 *
		 */
		protected override function addRender(render : SRender) : void
		{
			SLayerManager.getInstance().push(SLayerManager.LAYER_ENTITY, render);
		}
		
		protected override function removeRender(render : SRender) : void
		{
			SLayerManager.getInstance().push(SLayerManager.LAYER_ENTITY, render);
		}

		override public function dispose() : void
		{
			super.dispose();
			mResource && mResource.dispose();
			mResource = null;
		}
	}
}