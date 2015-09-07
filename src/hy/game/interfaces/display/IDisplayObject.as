package hy.game.interfaces.display
{

	public interface IDisplayObject
	{
		function get x() : Number;
		function set x(value : Number) : void;
		function get y() : Number;
		function set y(value : Number) : void;
		function get alpha() : Number;
		function set alpha(value : Number) : void;
		function set scaleX(value : Number) : void;
		function get scaleX() : Number;
		function set scaleY(value : Number) : void;
		function get scaleY() : Number;
		function get width() : Number;
		function set width(value : Number) : void;
		function get height() : Number;
		function set height(value : Number) : void;
		/**
		 * 旋转弧度 
		 * @param value
		 * 
		 */
		function set rotation(value : Number) : void;
		/**
		 * 旋转弧度  
		 * @return 
		 * 
		 */
		function get rotation() : Number;
		function set visible(value : Boolean) : void;
		function get visible() : Boolean;

		function get name() : String;
		function set name(value : String) : void;
		/**
		 * 层级,深度 
		 * @return 
		 * 
		 */
		function get layer() : int;
		/**
		 * 层级,深度 
		 * @param value
		 * 
		 */
		function set layer(value : int) : void;

		/**
		 * 从父类移除
		 * @param dispose
		 *
		 */
		function removeFromParent(dispose : Boolean = false) : void;
		/**
		 * 设置父类容器
		 * @param value
		 *
		 */
		function setParent(value : IDisplayContainer) : void;
		/**
		 * 渲染
		 *
		 */
		function render() : void;
		/**
		 * 销毁 
		 * 
		 */
		function dispose() : void;
	}
}