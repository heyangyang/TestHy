package hy.game.components
{
	import hy.game.core.FrameComponent;
	import hy.game.data.STransform;
	import hy.game.render.SRender;

	/**
	 * 渲染基本组件
	 * @author hyy
	 *
	 */
	public class SRenderComponent extends FrameComponent
	{
		protected var m_render : SRender;
		protected var m_transform : STransform;
		protected var m_offsetX : int;
		protected var m_offsetY : int;

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
			m_render = new SRender();
		}

		/**
		 * 继承的子类，必须调用该类方法
		 *
		 */
		override protected function onStart() : void
		{
			addRender(m_render);
			m_render.notifyAddedToRender();
			m_transform = m_owner.transform;
		}

		override public function notifyAdded():void
		{
			super.notifyAdded();
			m_offsetX = m_offsetY = 0;
		}
		
		/**
		 * 继承的子类，必须调用该类方法
		 *
		 */
		override public function notifyRemoved() : void
		{
			removeRender(m_render);
			m_render.notifyRemovedFromRender();
			m_transform = null;
		}

		override public function update() : void
		{

		}

		protected function addRender(render : SRender) : void
		{
			m_owner && m_owner.addRender(render);
		}

		protected function removeRender(render : SRender) : void
		{
			m_owner && m_owner.removeRender(render);
		}

		override public function destroy() : void
		{
			super.destroy();
		}

		public function setOffsetXY(x : int, y : int) : void
		{
			m_offsetX = x;
			m_offsetY = y;
		}

		public function set offsetX(value : int) : void
		{
			m_offsetX = value;
		}

		public function set offsetY(value : int) : void
		{
			m_offsetY = value;
		}

	}
}