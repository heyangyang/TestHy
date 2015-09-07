package hy.game.interfaces.display
{

	public interface IDisplayContainer extends IDisplayObject
	{
		/**
		 * 根据layer采用二分插入法插入
		 * @param render
		 *
		 */
		function addDisplay(render : IDisplayObject) : void;
		/**
		 * 移除
		 * @param child
		 * @param dispose 是否销毁,如果是纹理则销毁纹理
		 *
		 */
		function removeDisplay(child : IDisplayObject, dispose : Boolean = false) : void;

		function get filters() : Array;
		function set filters(value : Array) : void;
	}
}