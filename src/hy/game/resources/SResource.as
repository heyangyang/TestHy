package hy.game.resources
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	
	import hy.game.cfg.Config;
	import hy.game.core.SReference;
	import hy.game.namespaces.name_part;

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
		private var m_priority : int;
		/**
		 * 加载地址
		 */
		private var m_url : String;

		public var version : String;
		/**
		 * 名称
		 */
		public var name : String;

		private var m_isLoaded : Boolean = false;

		private var m_isLoading : Boolean = false;

		private var m_isStartLoad : Boolean;
		/**
		 * 当前重复加载次数
		 */
		private var m_currCount : int = 0;
		/**
		 * 加载成功后回调
		 */
		protected var m_notifyCompleteds : Vector.<Function>;
		/**
		 * 报错后回调
		 */
		protected var m_notifyIOErrors : Vector.<Function>;
		/**
		 * 进度条
		 */
		protected var m_notifyProgresses : Vector.<Function>;
		/**
		 * 加载地址
		 */
		protected var request : URLRequest;
		private var m_bytesTotal : Number = 300 * 1000;
		private var m_bytesLoaded : Number;
		name_part var old_bytesTotal : Number;
		name_part var old_bytesLoaded : Number;

		protected var context : LoaderContext;

		public function SResource(res_url : String, version : String)
		{
			this.m_url = res_url;
			this.version = version;
			if (version)
				res_url += "?" + version;
			this.request = new URLRequest(encodeURI(res_url));
		}


		/**
		 * 开始加载,需要手动调用load
		 *
		 */
		public function load() : void
		{
			if ( SResourceMagnger.getInstance().addLoader(this))
				this.m_isLoading = true;
		}

		/**
		 *
		 *
		 */
		name_part function startLoad(context : LoaderContext = null) : void
		{
			this.context = context;
		}

		name_part function set isStartLoad(value : Boolean) : void
		{
			m_isStartLoad = value;
		}

		/**
		 * 是否在加载队列里面
		 */
		name_part function get isStartLoad() : Boolean
		{
			return m_isStartLoad;
		}

		public function get url() : String
		{
			return m_url;
		}
		
		public function priority(value:int) : SResource
		{
			m_priority=value;
			return this;
		}
		
		/**
		 * 正在加载
		 * @return
		 *
		 */
		public function get isLoading() : Boolean
		{
			return m_isLoading;
		}

		/**
		 * 是否加载完成
		 * @return
		 *
		 */
		public function get isLoaded() : Boolean
		{
			return m_isLoaded;
		}

		/**
		 * 总共下载大小
		 * 默认是300k 300 * 1000
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
			if (!m_notifyCompleteds)
				m_notifyCompleteds = new Vector.<Function>();
			if (m_notifyCompleteds.indexOf(notifyFunction) == -1)
				m_notifyCompleteds.push(notifyFunction);
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
			if (!m_notifyIOErrors)
				m_notifyIOErrors = new Vector.<Function>();
			if (m_notifyIOErrors.indexOf(notifyFunction) == -1)
				m_notifyIOErrors.push(notifyFunction);
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
			if (!m_notifyProgresses)
				m_notifyProgresses = new Vector.<Function>();
			if (m_notifyProgresses.indexOf(notifyFunction) == -1)
				m_notifyProgresses.push(notifyFunction);
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
			old_bytesTotal = m_bytesLoaded;
			old_bytesLoaded = m_bytesLoaded;
			if (evt.bytesTotal > 0)
				m_bytesTotal = evt.bytesTotal;
			m_bytesLoaded = evt.bytesLoaded;
			SResourceMagnger.getInstance().updateProgress(this);
			invokeNotifyByArray(m_notifyProgresses);
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
			m_isLoaded = true;
			m_isLoading = false;
			cleanListeners();
			invokeNotifyByArray(m_notifyCompleteds);
		}

		/**
		 * 加载异常输出
		 * @param msg
		 *
		 */
		protected function onFailed(msg : String) : void
		{
			//3次尝试重新加载
			if (m_currCount < Config.MAX_RELOAD)
			{
				m_currCount++;
				startLoad(context);
				error("load again: ", m_currCount, request.url);
				return;
			}
			removeLoader();
			m_isLoading = false;
			error("load error: ", this.m_url);
			cleanListeners();
			invokeNotifyByArray(m_notifyIOErrors);
		}

		public function get data():*
		{
			
		}
			
		/**
		 * 从加载队列中移除
		 *
		 */
		private function removeLoader() : void
		{
			m_isLoading=false;
			m_isStartLoad && SResourceMagnger.getInstance().removeLoader(this);
		}

		/**
		 * 停止下载
		 *
		 */
		public function stop() : void
		{
			removeLoader();
			m_isLoading = false;
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
			request = null;
			context = null;
			super.destroy();
		}

	}
}