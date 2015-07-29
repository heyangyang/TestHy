package hy.game.starter
{
	public interface IStartNode
	{
		function onStart():void;
		function update():void;
		function onExit():void;
		function get id():String;
	}
}