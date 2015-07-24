package hy.game.net.interfaces
{

	public interface INotify
	{
		function handleMessage(protocolId : uint, param : Object) : void;
	}
}