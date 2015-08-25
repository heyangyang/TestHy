package hy.game.resources
{
	import flash.utils.Dictionary;

	import hy.game.manager.SBaseManager;
	import hy.game.manager.SReferenceManager;

	/**
	 * 按照配置文件加载
	 * @author hyy
	 *
	 */
	public class SPreLoad extends SBaseManager
	{
		private static var instance : SPreLoad;
//		private var file_dic : Dictionary;
		/**
		 * 批量加载地址
		 */
		private var batchData : Dictionary;
		private var onComplete : Function;
		private var onProgress : Function;
		private var m_isLoading : Boolean;
		private var m_loadCount : int;
		private var m_loadIndex : int;
		private var resourceMgr : SResourceMagnger;

		public function SPreLoad()
		{
			if (instance)
				error("instance != null");
			resourceMgr = SResourceMagnger.getInstance();
		}

		public static function getInstance() : SPreLoad
		{
			if (instance == null)
				instance = new SPreLoad();
			return instance;
		}

		/**
		 * 加载成功
		 * @param res
		 *
		 */
		public function onConfigComplete(xml : XML) : void
		{
//			file_dic = new Dictionary();
//			var xmlList : XMLList = xml.file;
//			var len : int = xmlList.length();
//			var fileData : Object;
//			var child : XML;
//			for (var i : int = 0; i < len; i++)
//			{
//				child = xmlList[i];
//				fileData = {id: child.@id, v: child.@version, url: child.@url};
//				file_dic[fileData.id] = fileData;
//			}

			batchData = new Dictionary();
			var batchArray : Array;
			var xmlList : XMLList = xml.batch;
			var len : int = xmlList.length();
			var count : int;
			var child : XML;
			for (var i : int = 0; i < len; i++)
			{
				child = xmlList[i];
				//预加载的id
				count = child.file.length();
				//id所对应的一系列资源地址
				batchArray = [];

				for (var j : int = 0; j < count; j++)
				{
					batchArray.push(child.file[j].@id.toString());
				}
				batchData[String(child.@id)] = batchArray;
			}
		}


		/**
		 * 根据id进行批量加载
		 * @param id
		 * @param callFun
		 *
		 */
		public function bathLoad(id : String, onComplete : Function = null, onProgress : Function = null) : void
		{
			if (m_isLoading)
			{
				warning("preLoad is loading");
				return;
			}
			var loads : Array = id.split(",");
			this.onComplete = onComplete;
			this.onProgress = onProgress;
			startLoadByArray(loads)

		}

		/**
		 * 根据id进行后台加载
		 * @param id
		 * @param callFun
		 *
		 */
		public function preLoad(id : String, onComplete : Function = null, onProgress : Function = null) : void
		{
			if (m_isLoading)
			{
				warning("preLoad is loading");
				return;
			}
			if (batchData[id] == null)
			{
				error("preLoad id :" + id + " = null");
				return;
			}
			this.onComplete = onComplete;
			this.onProgress = onProgress;
			startLoadByArray(batchData[id])
		}

		private function startLoadByArray(load_list : Array) : void
		{
			if (!load_list)
			{
				warning(this, "load_list=null");
				return;
			}
			m_loadCount = load_list.length;
			m_loadIndex = 0;
			var referenceMgr : SReferenceManager = SReferenceManager.getInstance();
			var id : String;
			for (var i : int = 0; i < m_loadCount; i++)
			{
				referenceMgr.createResource(load_list[i]).addNotifyCompleted(onCompleteHandler).addNotifyProgress(onProgressHandler).load();
			}
		}

		private function onCompleteHandler(res : SResource) : void
		{
			if (++m_loadIndex < m_loadCount)
				return;
			onComplete != null && onComplete(this);
		}

		private function onProgressHandler(res : SResource) : void
		{
			onProgress != null && onProgress(this);
		}

		public function get isLoading() : Boolean
		{
			return m_isLoading;
		}

		/**
		 * 总共下载大小
		 */
		public function get bytesTotal() : Number
		{
			return resourceMgr.bytesTotal;
		}

		/**
		 * 当前加载大小
		 */
		public function get bytesLoaded() : Number
		{
			return resourceMgr.bytesLoaded;
		}

		private function clear() : void
		{
			m_isLoading = false;
			onComplete = null;
			onProgress = null;
		}
	}
}