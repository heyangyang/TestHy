package hy.game.starter
{
	import flash.utils.Dictionary;

	import hy.game.utils.SDebug;

	/**
	 * 启动器基类
	 * @author wait
	 *
	 */
	public class SGameStartBase
	{
		private var m_nodes : Vector.<SStartNode>;
		private var m_nodeTypes : Dictionary;
		private var m_excuteNode : SStartNode;
		private var m_isRunning : Boolean;

		public function SGameStartBase()
		{
			m_nodes = new Vector.<SStartNode>();
			m_nodeTypes = new Dictionary();
		}

		public function onStart() : void
		{

		}

		public function addNodeByClass(node_class : Class) : void
		{
			var node : SStartNode = new node_class();
			if (!node.id)
				SDebug.error(this, "id==null");
			if (m_nodeTypes[node.id])
				SDebug.error(this, "id  exist");
			m_nodeTypes[node.id] = node;
		}

		/**
		 * 按照添加顺序，运行启动器
		 * @param type
		 *
		 */
		public function addNodeByType(type : String) : void
		{
			var node : SStartNode = m_nodeTypes[type];
			if (node == null)
				SDebug.error(this, "not find id:" + type);
			m_nodes.push(node);
		}

		public function run() : void
		{
			if (m_isRunning)
			{
				SDebug.warning(this, "isRunning");
				return;
			}
			m_isRunning = true;
			nextNode();
		}

		private function nextNode() : void
		{
			if (m_nodes.length == 0)
			{
				m_isRunning = false;
				return;
			}
			m_excuteNode && m_excuteNode.onExit();
			m_excuteNode = m_nodes.shift();
			m_excuteNode.setHandler(nextNode);
			m_excuteNode.onStart();
		}

		/**
		 * 启动器是否在运行
		 * @return
		 *
		 */
		public function get isRunnging() : Boolean
		{
			return m_isRunning;
		}
	}
}