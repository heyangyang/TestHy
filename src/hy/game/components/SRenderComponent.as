package hy.game.components
{
	import hy.game.core.FrameComponent;
	import hy.game.render.SGameRender;

	public class SRenderComponent extends FrameComponent
	{
		private var m_render : SGameRender;

		public function SRenderComponent(type : *)
		{
			super(type);
		}

		override protected function onStart() : void
		{
			m_render = new SGameRender();
		}

		override public function notifyAdded() : void
		{
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
			updateRender();
		}

		protected function updateRenderProperty() : void
		{
		}

		protected function updateRender() : void
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
	}
}