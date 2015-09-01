package hy.game.manager
{
	import flash.utils.Dictionary;

	import hy.game.core.GameObject;
	import hy.game.interfaces.core.IEnterFrame;

	/**
	 * 游戏对象管理器
	 * @author hyy
	 *
	 */
	public class GameObjectManager extends SBaseManager implements IEnterFrame
	{
		private static var instance : GameObjectManager;

		public static function getInstance() : GameObjectManager
		{
			if (instance == null)
				instance = new GameObjectManager();
			return instance;
		}

		private var mNameDictionary : Dictionary;
		private var mTagsDictionary : Dictionary;
		private var mChilds : Vector.<GameObject>;
		private var mNumChildren : int;
		private var mCurrChild : GameObject;

		public function GameObjectManager()
		{
			if (instance)
				error("instance != null");
			mNameDictionary = new Dictionary();
			mTagsDictionary = new Dictionary();
			mChilds = new Vector.<GameObject>();
			mNumChildren = 0;
		}

		/**
		 * 每帧调用一次
		 *
		 */
		public function update() : void
		{
			for (var i : int = mNumChildren - 1; i >= 0; i--)
			{
				mCurrChild = mChilds[i];
				if (mCurrChild.isDispose || !mCurrChild.activeStatus || !mCurrChild.checkUpdatable())
					continue;
				mCurrChild.update();
			}
		}

		/**
		 * 名字查找
		 * @param name
		 * @return
		 *
		 */
		public function findGameObject(name : String) : GameObject
		{
			if (mNameDictionary[name] == null)
				return null;
			return mNameDictionary[name][0];
		}


		/**
		 * 查找所有相同名字的对象
		 * @param name
		 * @return
		 *
		 */
		public function findGameObjects(name : String) : Array
		{
			if (mNameDictionary[name] == null)
				return null;
			return mNameDictionary[name];
		}

		/**
		 * 标记查找
		 * @param name
		 * @return
		 *
		 */
		public function findWithTag(name : String) : GameObject
		{
			if (mTagsDictionary[name] == null)
				return null;
			return mTagsDictionary[name][0];
		}

		/**
		 * 查找所有相同标记的对象
		 * @param name
		 * @return
		 *
		 */
		public function findWithTags(name : String) : Array
		{
			if (mTagsDictionary[name] == null)
				return null;
			return mTagsDictionary[name];
		}

		/**
		 * 添加游戏对象
		 * @param child
		 *
		 */
		public function push(child : GameObject) : void
		{
			if (mChilds.indexOf(child) != -1)
				return;
			sort2Push(child);
			mNumChildren++;
			addGameObject(child.name, child, mNameDictionary);
			addGameObject(child.tag, child, mTagsDictionary);
		}

		/**
		 * 移除游戏对象
		 * @param child
		 *
		 */
		public function remove(child : GameObject) : void
		{
			var index : int = mChilds.indexOf(child);
			if (index == -1)
				return;
			mChilds.splice(index, 1);
			mNumChildren--;
			removeGameObject(child.name, child, mNameDictionary);
			removeGameObject(child.tag, child, mTagsDictionary);
		}

		/**
		 * 2分插入法
		 * @param child
		 *
		 */
		private function sort2Push(child : GameObject) : void
		{
			if (mNumChildren == 0)
			{
				mChilds.push(child);
				return;
			}
			var tIndex : int = mChilds.indexOf(child);
			//比较的索引
			var tSortIndex : int;
			//区间A，A-B,默认0开始
			var tStartSortIndex : int = 0;
			//区间B，A-B，默认数组长度
			var tEndSortIndex : int = mNumChildren - 1;
			//计算次数
			var tCount : int = 1;
			//每次计算后，区间值
			var tValue : int = tSortIndex = Math.ceil(mNumChildren - 1 >> tCount);
			while (tValue > 0)
			{
				tValue = Math.ceil(mNumChildren - 1 >> ++tCount);
				//如果是自己，则比较前后一个
				if (tSortIndex == tIndex)
				{
					if (child.priority > mChilds[tSortIndex + 1].priority)
						tSortIndex++;
					else
						tSortIndex--;
				}
				//向后查找
				if (child.priority > mChilds[tSortIndex].priority)
				{
					tStartSortIndex = tSortIndex;
					tSortIndex += tValue;
				}
				//向前查找
				else
				{
					tEndSortIndex = tSortIndex;
					tSortIndex -= tValue;
				}
			}
			for (tSortIndex = tStartSortIndex; tSortIndex <= tEndSortIndex; tSortIndex++)
			{
				if (child.priority < mChilds[tSortIndex].priority)
				{
					break;
				}
			}

			//移除以前的
			if (tIndex != -1)
				mChilds.splice(tIndex, 1);
			if (tIndex >= 0 && tIndex < tSortIndex)
				tSortIndex--;
			if (tSortIndex < 0)
				tSortIndex = 0;
			//插入
			mChilds.splice(tSortIndex, 0, child);
		}

		private function addGameObject(name : String, gameObject : GameObject, dic : Dictionary) : void
		{
			if (!name)
				return;
			var list : Array;
			if (dic[name] == null)
				dic[name] = [];
			list = dic[name];
			if (list.indexOf(gameObject) == -1)
				list.push(gameObject);
		}

		private function removeGameObject(name : String, gameObject : GameObject, dic : Dictionary) : void
		{
			if (!name)
				return;
			var list : Array;
			if (dic[name] == null)
				dic[name] = [];
			list = dic[name];
			var index : int = list.indexOf(gameObject);
			if (index != -1)
				list.splice(index, 1);
		}
	}
}