package hy.game.core.interfaces
{

	/**
	 *更新接口
	 * @author hyy
	 *
	 */
	public interface IUpdate extends IDispose
	{
		function update() : void
		/**
		 * 为每一个需要Update的对象定义一个帧频数
		 * @param value
		 *
		 */
		function set frameRate(value : uint) : void;
		function get frameRate() : uint;

		/**
		 * 更新间隔
		 * @param value
		 *
		 */
		function set frameInterval(value : uint) : void;
		function get frameInterval() : uint;

		/**
		 * 优先级
		 * @return
		 */
		function get priority() : int;
		function set priority(value : int) : void;

		/**
		 * 注册
		 * @param level
		 * @param priority
		 *
		 */
		function registerd(priority : int = 0) : void;
		function unRegisterd() : void;

		/**
		 * 检测时候可以更新
		 * @param elapsedTime
		 * @return
		 *
		 */
		function checkUpdatable() : Boolean;
	}
}