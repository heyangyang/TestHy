package hy.game.starter
{
	import hy.game.namespaces.name_part;

	/**
	 * 启动器节点 
	 * @author wait
	 * 
	 */
	public class SStartNode implements IStartNode
	{
		private var m_excuteHandler:Function;
		public function SStartNode()
		{
		
		}
		
		/**
		 * 启动器初始化 
		 * 
		 */
		public function onStart():void
		{
		}
		
		public function update():void
		{
		}
		
		/**
		 * 启动器退出 
		 * 
		 */
		public function onExit():void
		{
		}
		
		public function setHandler(excuteHandler:Function):void
		{
			this.m_excuteHandler=excuteHandler;
		}
		/**
		 * 下一个节点 
		 * 
		 */
		name_part function nextNode():void
		{
			m_excuteHandler !=null && m_excuteHandler();
			m_excuteHandler=null;
		}
		
		/**
		 * 必须覆盖 
		 * @return 
		 * 
		 */
		public function get id():String
		{
			return null;
		}
	}
}