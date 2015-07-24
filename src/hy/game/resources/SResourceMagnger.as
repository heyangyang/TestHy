package hy.game.resources
{
	import flash.system.ApplicationDomain;
	import flash.system.ImageDecodingPolicy;
	import flash.system.LoaderContext;
	
	import hy.game.manager.SBaseManager;
	import hy.game.manager.SReferenceManager;
	import hy.game.namespaces.name_part;

	use namespace name_part;

	/**
	 * 批量下载
	 * @author hyy
	 *
	 */
	public class SResourceMagnger extends SBaseManager
	{
		private static var instance : SResourceMagnger;

		public static function getInstance() : SResourceMagnger
		{
			if (instance == null)
			{
				instance = new SResourceMagnger();
				instance.init();
			}
			return instance;
		}

		public var context : LoaderContext;

		/**
		 * 需要下载的队列
		 */
		private var waitLoad_list : Vector.<SResource>;
		/**
		 * 正在加载的队列
		 */
		private var loading_list : Vector.<SResource>;
		/**
		 * 是否需要排序
		 */
		private var m_sort : Boolean;

		/**
		 * 最大并发加载数量
		 */
		private var m_maxLoadCount : int;

		private var m_bytesTotal : Number;

		private var m_bytesLoaded : Number;

		public function SResourceMagnger(count : int = 2)
		{
			m_maxLoadCount = count;
		}

		private function init() : void
		{
			context = new LoaderContext();
			context.applicationDomain = ApplicationDomain.currentDomain;
			context.imageDecodingPolicy = ImageDecodingPolicy.ON_LOAD;
			context.checkPolicyFile = false;

			m_sort = false;
			waitLoad_list = new Vector.<SResource>();
			loading_list = new Vector.<SResource>();
		}

		name_part function addLoader(res : SResource) : Boolean
		{
			if (waitLoad_list.indexOf(res) != -1 || !res)
				return false;
			waitLoad_list.push(res);
			m_sort = true;
			loadNext();
			return true;
		}

		name_part function removeLoader(res : SResource) : void
		{
			if (res.isLoaded)
				return;
			if (!res.isStartLoad)
				removeLoaderByList(res, waitLoad_list);
			else
				removeLoaderByList(res, loading_list);
			loadNext();
			//清零
			if (waitLoad_list.length == 0 || loading_list.length == 0)
				m_bytesLoaded = m_bytesTotal = 0;
		}

		/**
		 * 总共下载大小
		 */
		public function get bytesTotal() : Number
		{
			return m_bytesTotal;
		}

		/**
		 * 当前加载大小
		 */
		public function get bytesLoaded() : Number
		{
			return m_bytesLoaded;
		}

		/**
		 * 更新总加载进度
		 * @param res
		 *
		 */
		name_part function updateProgress(res : SResource) : void
		{
			//先减去上一次的进度
			m_bytesLoaded += res.old_bytesLoaded;
			m_bytesTotal += res.old_bytesTotal;
			//加上更新后的进度
			m_bytesLoaded += res.bytesLoaded;
			m_bytesTotal += res.bytesTotal;
		}

		private function removeLoaderByList(res : SResource, list : Vector.<SResource>) : void
		{
			var index : int = list.indexOf(res);
			if (index != -1)
			{
				list.splice(index, 1);
				res.isStartLoad = false;
			}
		}

		private function loadNext() : void
		{
			if (loading_list.length >= m_maxLoadCount || waitLoad_list.length == 0)
				return;
			m_sort && waitLoad_list.sort("priority");
			var res : SResource = waitLoad_list.pop();
			res.isStartLoad = true;
			loading_list.push(res);
			m_bytesLoaded += res.bytesLoaded;
			m_bytesTotal += res.bytesTotal;
			res.startLoad(context);
		}

		public function createResource(id : String, version : String = null, root : String = null) : SResource
		{
			return SReferenceManager.getInstance().createResource(id, version, root);
		}

		public function getClass(name : String) : Class
		{
			if (ApplicationDomain.currentDomain.hasDefinition(name))
				return ApplicationDomain.currentDomain.getDefinition(name) as Class;
			waring("not find class:" + name);
			return null;
		}
	}
}