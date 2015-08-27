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
		private var mNodes : Vector.<SStartNode>;
		private var mNodeTypes : Dictionary;
		private var mExcuteNode : SStartNode;
		private var mIsRunning : Boolean;

		public function SGameStartBase()
		{
			mNodes = new Vector.<SStartNode>();
			mNodeTypes = new Dictionary();
		}

		public function onStart() : void
		{

		}

		public function addNodeByClass(node_class : Class) : void
		{
			var node : SStartNode = new node_class();
			if (!node.id)
				SDebug.error(this, "id==null");
			if (mNodeTypes[node.id])
				SDebug.error(this, "id  exist");
			mNodeTypes[node.id] = node;
		}

		/**
		 * 按照添加顺序，运行启动器
		 * @param type
		 *
		 */
		public function addNodeByType(type : String) : void
		{
			var node : SStartNode = mNodeTypes[type];
			if (node == null)
				SDebug.error(this, "not find id:" + type);
			mNodes.push(node);
		}

		public function run() : void
		{
			if (mIsRunning)
			{
				SDebug.warning(this, "isRunning");
				return;
			}
			mIsRunning = true;
			nextNode();
		}

		private function nextNode() : void
		{
			if (mNodes.length == 0)
			{
				mIsRunning = false;
				return;
			}
			mExcuteNode && mExcuteNode.onExit();
			mExcuteNode = mNodes.shift();
			mExcuteNode.setHandler(nextNode);
			mExcuteNode.onStart();
		}

		/**
		 * 启动器是否在运行
		 * @return
		 *
		 */
		public function get isRunnging() : Boolean
		{
			return mIsRunning;
		}
	}
}