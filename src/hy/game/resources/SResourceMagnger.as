package hy.game.resources
{
	import flash.display.BitmapData;
	import flash.system.ApplicationDomain;
	import flash.system.ImageDecodingPolicy;
	import flash.system.LoaderContext;
	import flash.utils.Dictionary;
	
	import hy.game.core.interfaces.IBitmapData;
	import hy.game.manager.SBaseManager;
	import hy.game.namespaces.name_part;
	import hy.game.render.SDirectBitmapData;
	import hy.game.render.SRenderBitmapData;

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

		private var mContext : LoaderContext;

		/**
		 * 需要下载的队列
		 */
		private var mWaitLoadList : Vector.<SResource>;
		/**
		 * 正在加载的队列
		 */
		private var mLoadingList : Vector.<SResource>;
		/**
		 * 是否需要排序
		 */
		private var mSort : Boolean;

		/**
		 * 最大并发加载数量
		 */
		private var mMaxLoadCount : int;

		private var mBytesTotal : Number;

		private var mBytesLoaded : Number;

		/**
		 * 图片库
		 */
		private var mGlobalImage : Dictionary = new Dictionary();

		public function SResourceMagnger(count : int = 2)
		{
			if (instance)
				error("instance != null");
			mMaxLoadCount = count;
		}

		private function init() : void
		{
			mContext = new LoaderContext();
			mContext.applicationDomain = ApplicationDomain.currentDomain;
			mContext.imageDecodingPolicy = ImageDecodingPolicy.ON_LOAD;
			mContext.checkPolicyFile = false;

			mSort = false;
			mWaitLoadList = new Vector.<SResource>();
			mLoadingList = new Vector.<SResource>();
		}

		name_part function addLoader(res : SResource) : Boolean
		{
			if (mWaitLoadList.indexOf(res) != -1 || !res)
				return false;
			mWaitLoadList.push(res);
			mSort = true;
			loadNext();
			return true;
		}

		name_part function removeLoader(res : SResource) : void
		{
			if (res.isLoaded)
				return;
			if (!res.isStartLoad)
				removeLoaderByList(res, mWaitLoadList);
			else
				removeLoaderByList(res, mLoadingList);
			loadNext();
			//清零
			if (mWaitLoadList.length == 0 || mLoadingList.length == 0)
				mBytesLoaded = mBytesTotal = 0;
		}

		/**
		 * 总共下载大小
		 */
		public function get bytesTotal() : Number
		{
			return mBytesTotal;
		}

		/**
		 * 当前加载大小
		 */
		public function get bytesLoaded() : Number
		{
			return mBytesLoaded;
		}

		/**
		 * 更新总加载进度
		 * @param res
		 *
		 */
		name_part function updateProgress(res : SResource) : void
		{
			//先减去上一次的进度
			mBytesLoaded -= res.old_bytesLoaded;
			mBytesTotal -= res.old_bytesTotal;
			//加上更新后的进度
			mBytesLoaded += res.bytesLoaded;
			mBytesTotal += res.bytesTotal;
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
			if (mLoadingList.length >= mMaxLoadCount || mWaitLoadList.length == 0)
				return;
			mSort && mWaitLoadList.sort(onPrioritySortFun);
			var res : SResource = mWaitLoadList.pop();
			res.addNotifyCompleted(onCompleted);
			res.addNotifyIOError(onCompleted);
			mLoadingList.push(res);
			mBytesLoaded += res.bytesLoaded;
			mBytesTotal += res.bytesTotal;
			res.startLoad(mContext);
			res.isStartLoad = true;
		}

		private function onCompleted(res : SResource) : void
		{
			loadNext();
		}

		private function onPrioritySortFun(a : SResource, b : SResource) : int
		{
			if (a.priority > b.priority)
				return 1;
			if (a.priority < b.priority)
				return -1;
			return 0;
		}

		public function getClass(name : String) : Class
		{
			if (ApplicationDomain.currentDomain.hasDefinition(name))
				return ApplicationDomain.currentDomain.getDefinition(name) as Class;
			warning("not find class:" + name);
			return null;
		}

		/**
		 * 获取图片,不能销毁
		 * @param id
		 * @return
		 *
		 */
		public function getImageById(id : String, supportDirectX = false) : IBitmapData
		{
			if (mGlobalImage[id])
				return mGlobalImage[id];
			var resClass : Class = getClass(id);
			var source : BitmapData = new resClass();
			var bitmapData : IBitmapData = new SRenderBitmapData(source.width, source.height, true, 0);
			SRenderBitmapData(bitmapData).draw(source);
			if (supportDirectX)
			{
				var bmd : SRenderBitmapData = bitmapData as SRenderBitmapData;
				bitmapData = SDirectBitmapData.fromDirectBitmapData(bmd);
				bmd.dispose();
			}
			source.dispose();
			mGlobalImage[id] = bitmapData;
			return bitmapData;
		}

		public function setMaxLoadCount(value : int) : void
		{
			mMaxLoadCount = value;
		}
	}
}