package hy.game.components
{
	import hy.game.core.FrameComponent;
	import hy.game.data.STransform;
	import hy.game.manager.SLayerManager;
	import hy.game.render.SRender;

	/**
	 * 渲染基本组件
	 * @author hyy
	 *
	 */
	public class SRenderComponent extends FrameComponent
	{
		protected var mRender : SRender;
		protected var mTransform : STransform;
		protected var mOffsetX : int;
		protected var mOffsetY : int;
		protected var mIsVisible : Boolean = true;
		protected var mLayerType : String;

		public function SRenderComponent(type : * = null)
		{
			super(type);
		}

		/**
		 * 继承的子类，必须调用该类方法
		 *
		 */
		override protected function init() : void
		{
			mRender = new SRender();
		}

		/**
		 * 继承的子类，必须调用该类方法
		 *
		 */
		override protected function onStart() : void
		{
			updateRenderVisible();
			mTransform = mOwner.transform;
		}

		override public function notifyAdded() : void
		{
			super.notifyAdded();
			mOffsetX = mOffsetY = 0;
		}

		/**
		 * 继承的子类，必须调用该类方法
		 *
		 */
		override public function notifyRemoved() : void
		{
			removeRender(mRender);
			mTransform = null;
		}

		override public function update() : void
		{

		}

		public function setOffsetXY(x : int, y : int) : void
		{
			mOffsetX = x;
			mOffsetY = y;
		}

		public function set offsetX(value : int) : void
		{
			mOffsetX = value;
		}

		public function set offsetY(value : int) : void
		{
			mOffsetY = value;
		}

		public function setVisible(value : Boolean) : void
		{
			mIsVisible = value;
			updateRenderVisible();
		}

		/**
		 * 不添加到父类，直接添加到name层
		 * @param render
		 *
		 */
		protected function addRender(render : SRender) : void
		{
			!mLayerType && error(this, "mLayerType is null！");
			SLayerManager.getInstance().push(mLayerType, render);
		}

		protected function removeRender(render : SRender) : void
		{
			!mLayerType && error(this, "mLayerType is null！");
			SLayerManager.getInstance().remove(mLayerType, render);
		}

		protected function updateRenderVisible() : void
		{
			if (mIsVisible)
				addRender(mRender);
			else
				removeRender(mRender);
		}

		override public function dispose() : void
		{
			super.dispose();
			mTransform = null;
			removeRender(mRender);
		}
	}
}