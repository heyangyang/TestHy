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

		public static function getInstance() : SPreLoad
		{
			if (instance == null)
				instance = new SPreLoad();
			return instance;
		}
		/**
		 * 批量加载地址
		 */
		private var mBatchData : Dictionary;
		private var mOnComplete : Function;
		private var mOnProgress : Function;
		private var mIsLoading : Boolean;
		private var mLoadCount : int;
		private var mLoadIndex : int;
		private var mResourceMgr : SResourceMagnger;

		public function SPreLoad()
		{
			if (instance)
				error("instance != null");
			mResourceMgr = SResourceMagnger.getInstance();
		}

		/**
		 * 加载成功
		 * @param res
		 *
		 */
		public function onConfigComplete(xml : XML) : void
		{
			mBatchData = new Dictionary();
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
				mBatchData[String(child.@id)] = batchArray;
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
			if (mIsLoading)
			{
				warning("preLoad is loading");
				return;
			}
			var loads : Array = id.split(",");
			this.mOnComplete = onComplete;
			this.mOnProgress = onProgress;
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
			if (mIsLoading)
			{
				warning("preLoad is loading");
				return;
			}
			if (mBatchData[id] == null)
			{
				error("preLoad id :" + id + " = null");
				return;
			}
			this.mOnComplete = onComplete;
			this.mOnProgress = onProgress;
			startLoadByArray(mBatchData[id])
		}

		private function startLoadByArray(load_list : Array) : void
		{
			if (!load_list)
			{
				warning(this, "load_list=null");
				return;
			}
			mLoadCount = load_list.length;
			mLoadIndex = 0;
			var referenceMgr : SReferenceManager = SReferenceManager.getInstance();
			var id : String;
			for (var i : int = 0; i < mLoadCount; i++)
			{
				referenceMgr.createResource(load_list[i]).addNotifyCompleted(onCompleteHandler).addNotifyProgress(onProgressHandler).load();
			}
		}

		private function onCompleteHandler(res : SResource) : void
		{
			if (++mLoadIndex < mLoadCount)
				return;
			mOnComplete != null && mOnComplete(this);
		}

		private function onProgressHandler(res : SResource) : void
		{
			mOnProgress != null && mOnProgress(this);
		}

		public function get isLoading() : Boolean
		{
			return mIsLoading;
		}

		/**
		 * 总共下载大小
		 */
		public function get bytesTotal() : Number
		{
			return mResourceMgr.bytesTotal;
		}

		/**
		 * 当前加载大小
		 */
		public function get bytesLoaded() : Number
		{
			return mResourceMgr.bytesLoaded;
		}

		private function clear() : void
		{
			mIsLoading = false;
			mOnComplete = null;
			mOnProgress = null;
		}
	}
}