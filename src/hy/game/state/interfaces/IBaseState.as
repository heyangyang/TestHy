package hy.game.state.interfaces
{

	public interface IBaseState
	{
		function tryChangeState() : Boolean;
		function enterState() : void;
		function exitState() : void;
		function update() : void;
		function destory() : void;
		function get id() : int;
	}
}