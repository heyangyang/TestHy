package hy.game.net.interfaces
{
	import flash.utils.ByteArray;

	import hy.game.net.SByteArray;

	public interface IData
	{
		function serialize() : SByteArray;
		function deSerialize(data : ByteArray) : void;
		function get cmdId() : int;
	}
}