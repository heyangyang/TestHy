package hy.game.resources
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;
	
	import hy.game.cfg.Config;
	import hy.game.core.SReference;
	import hy.game.namespaces.name_part;
	import hy.game.utils.SByteArrayUtil;

	use namespace name_part;

	/**
	 * 加载的基类
	 * @author hyy
	 *
	 */
	public class SResource extends SReference
	{
		/**
		 *优先级别
		 */
		private var mPriority : int;
		/**
		 * 加载地址
		 */
		private var mUrl : String;

		public var version : String;
		/**
		 * 名称
		 */
		public var name : String;

		private var mIsLoaded : Boolean = false;

		private var mIsLoading : Boolean = false;

		private var mIsStartLoad : Boolean;
		/**
		 * 当前重复加载次数
		 */
		private var mCurrCount : int = 0;
		/**
		 * 加载成功后回调
		 */
		protected var mNotifyCompleteds : Vector.<Function>;
		/**
		 * 报错后回调
		 */
		protected var mNotifyIOErrors : Vector.<Function>;
		/**
		 * 进度条
		 */
		protected var mNotifyProgresses : Vector.<Function>;
		/**
		 * 加载地址
		 */
		protected var mRequest : URLRequest;
		private var mBytesTotal : Number = 300 * 1000;
		private var mBytesLoaded : Number;
		
		name_part var old_bytesTotal : Number;
		name_part var old_bytesLoaded : Number;

		protected var mContext : LoaderContext;

		public function SResource(res_url : String, version : String)
		{
			this.mUrl = res_url;
			this.version = version;
			if (version)
				res_url += "?v=" + version;
			this.mRequest = new URLRequest(encodeURI(res_url));
		}


		/**
		 * 开始加载,需要手动调用load
		 *
		 */
		public function load() : void
		{
			if (mIsLoading)
				return;
			if (mIsLoaded)
			{
				invokeNotifyByArray(mNotifyCompleteds);
				return;
			}
			if (SResourceMagnger.getInstance().addLoader(this))
				this.mIsLoading = true;
		}

		/**
		 *
		 *
		 */
		name_part function startLoad(context : LoaderContext = null) : void
		{
			this.mContext = context;
		}

		/**
		 * 重复加载
		 *
		 */
		protected function reload() : void
		{

		}

		name_part function set isStartLoad(value : Boolean) : void
		{
			mIsStartLoad = value;
		}

		/**
		 * 是否在加载队列里面
		 */
		name_part function get isStartLoad() : Boolean
		{
			return mIsStartLoad;
		}

		public function get url() : String
		{
			return mUrl;
		}

		public function setPriority(value : int) : SResource
		{
			mPriority = value;
			return this;
		}

		public function get priority() : int
		{
			return mPriority;
		}
		/**
		 * 正在加载
		 * @return
		 *
		 */
		public function get isLoading() : Boolean
		{
			return mIsLoading;
		}

		/**
		 * 是否加载完成
		 * @return
		 *
		 */
		public function get isLoaded() : Boolean
		{
			return mIsLoaded;
		}

		/**
		 * 总共下载大小
		 * 默认是300k 300 * 1000
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
		 * 清除监听
		 *
		 */
		public function cleanListeners() : void
		{

		}

		/**
		 * 加载完成通知处理函数
		 * @param notifyFunction
		 * @return
		 *
		 */
		public function addNotifyCompleted(notifyFunction : Function) : SResource
		{
			if (notifyFunction == null)
				return this;
			if (!mNotifyCompleteds)
				mNotifyCompleteds = new Vector.<Function>();
			if (mNotifyCompleteds.indexOf(notifyFunction) == -1)
				mNotifyCompleteds.push(notifyFunction);
			return this;
		}

		/**
		 * 加载错误通知处理函数
		 * @param notifyFunction
		 * @return
		 *
		 */
		public function addNotifyIOError(notifyFunction : Function) : SResource
		{
			if (notifyFunction == null)
				return this;
			if (!mNotifyIOErrors)
				mNotifyIOErrors = new Vector.<Function>();
			if (mNotifyIOErrors.indexOf(notifyFunction) == -1)
				mNotifyIOErrors.push(notifyFunction);
			return this;
		}

		/**
		 * 加载进度通知处理函数
		 * @param notifyFunction
		 * @return
		 *
		 */
		public function addNotifyProgress(notifyFunction : Function) : SResource
		{
			if (notifyFunction == null)
				return this;
			if (!mNotifyProgresses)
				mNotifyProgresses = new Vector.<Function>();
			if (mNotifyProgresses.indexOf(notifyFunction) == -1)
				mNotifyProgresses.push(notifyFunction);
			return this;
		}

		private function invokeNotifyByArray(functions : Vector.<Function>) : void
		{
			if (!functions)
				return;
			for each (var notify : Function in functions)
			{
				notify(this);
			}
			functions.length = 0;
		}

		/**
		 * 加载进度条
		 * @param evt
		 *
		 */
		protected function onProgressEvent(evt : ProgressEvent) : void
		{
			//记录上一次的数据
			old_bytesTotal = mBytesLoaded;
			old_bytesLoaded = mBytesLoaded;
			if (evt.bytesTotal > 0)
				mBytesTotal = evt.bytesTotal;
			mBytesLoaded = evt.bytesLoaded;
			SResourceMagnger.getInstance().updateProgress(this);
			invokeNotifyByArray(mNotifyProgresses);
		}

		protected function onDownloadError(evt : IOErrorEvent) : void
		{
			onFailed(evt.text);
		}

		protected function onDownloadSecurityError(evt : SecurityErrorEvent) : void
		{
			onFailed(evt.text);
		}

		/**
		 * 加载完成
		 * @param evt
		 *
		 */
		protected function onDownLoadComplete(evt : Event) : void
		{
			removeLoader();
			mIsLoaded = true;
			mIsLoading = false;
			cleanListeners();
			invokeNotifyByArray(mNotifyCompleteds);
		}

		/**
		 * 加载异常输出
		 * @param msg
		 *
		 */
		protected function onFailed(msg : String) : void
		{
			//3次尝试重新加载
			if (mCurrCount < Config.MAX_RELOAD)
			{
				mCurrCount++;
				reload();
				warning("load again: ", mCurrCount, mRequest.url);
				return;
			}
			removeLoader();
			mIsLoading = false;
			error("load error: ", this.mUrl);
			cleanListeners();
			invokeNotifyByArray(mNotifyIOErrors);
		}

		public function get data() : *
		{

		}

		public function getBinary() : *
		{
			var bytes : ByteArray = data;
			if (bytes == null)
				return null;
			return SByteArrayUtil.decryptByteArray(bytes);
		}

		/**
		 * 从加载队列中移除
		 *
		 */
		private function removeLoader() : void
		{
			mIsLoading = false;
			mIsStartLoad && SResourceMagnger.getInstance().removeLoader(this);
		}

		/**
		 * 停止下载
		 *
		 */
		public function stop() : void
		{
			removeLoader();
			mIsLoading = false;
			cleanListeners();
		}

		/**
		 * 销毁
		 *
		 */
		override protected function destroy() : void
		{
			if (isDisposed)
				return;
			stop();
			cleanListeners();
			mRequest = null;
			mContext = null;
			super.destroy();
		}

	}
}