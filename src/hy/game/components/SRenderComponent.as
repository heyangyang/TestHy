package hy.game.components
{
	import hy.game.core.FrameComponent;
	import hy.game.data.STransform;
	import hy.game.render.SGameRender;

	/**
	 * 渲染基本组件
	 * @author hyy
	 *
	 */
	public class SRenderComponent extends FrameComponent
	{
		protected var m_render : SGameRender;
		protected var m_transform:STransform;
		protected var m_offsetX:int;
		protected var m_offsetY:int;
		public function SRenderComponent(type : * = null)
		{
			super(type);
		}

		override protected function onStart() : void
		{
			m_render = new SGameRender();
		}

		override public function notifyAdded() : void
		{
			m_transform=m_owner.transform;
			m_render.notifyAddedToRender();
			addRender(m_render);
		}

		override public function notifyRemoved() : void
		{
			m_render.notifyRemovedFromRender();
			removeRender(m_render);
		}

		override public function update() : void
		{
			
		}

		protected function addRender(render : SGameRender) : void
		{
			m_owner && m_owner.addRender(render);
		}

		protected function removeRender(render : SGameRender) : void
		{
			m_owner && m_owner.removeRender(render);
		}

		override public function destroy() : void
		{
			super.destroy();
		}

		public function set offsetX(value:int):void
		{
			m_offsetX = value;
		}
		
		public function set offsetY(value:int):void
		{
			m_offsetY = value;
		}

	}
}