package hy.game.net
{
	import flash.utils.ByteArray;

	import hy.game.interfaces.core.IDispose;
	import hy.game.net.interfaces.IData;

	public class SNetBaseData implements IData, IDispose
	{
		public static const TYPE_INT : int = 1;
		public static const TYPE_BYTE : int = 2;
		public static const TYPE_SHORT : int = 3;
		public static const TYPE_STRING : int = 4;
		public static const TYPE_OBJECT : int = 5;

		protected var mCmdId : int;
		protected var mData : ByteArray;

		public function SNetBaseData()
		{
		}

		public function serialize() : SByteArray
		{
			return null;
		}

		public function deSerialize(data : ByteArray) : void
		{
			this.mData = data;
		}

		public function get cmdId() : int
		{
			return mCmdId;
		}

		/**
		 *
		 * @param value
		 * @param byte
		 * @param type  1int，2byte,3short,4string,5obj
		 *
		 */
		protected function writeArray(value : Array, byte : ByteArray, type : int) : void
		{
			if (value == null)
			{
				byte.writeShort(0);
				return;
			}
			var len : int = value.length;
			var i : int = 0;
			byte.writeShort(len);

			switch (type)
			{
				case TYPE_INT:
					for (i = 0; i < len; i++)
					{
						byte.writeInt(value[i]);
					}
					break;
				case TYPE_BYTE:
					for (i = 0; i < len; i++)
					{
						byte.writeByte(value[i]);
					}
					break;
				case TYPE_SHORT:
					for (i = 0; i < len; i++)
					{
						byte.writeShort(value[i]);
					}
					break;
				case TYPE_STRING:
					for (i = 0; i < len; i++)
					{
						byte.writeUTF(value[i]);
					}
					break;
				case TYPE_OBJECT:
					for (i = 0; i < len; i++)
					{
						byte.writeBytes(value[i].serialize());
					}
					break;
			}
		}


		protected function readArrayInt() : Array
		{
			var tmpArr : Array = [];

			for (var i : int = mData.readShort() - 1; i >= 0; i--)
			{
				tmpArr.push(mData.readInt());
			}
			return tmpArr;
		}

		protected function readArrayString() : Array
		{
			var tmpArr : Array = [];

			for (var i : int = mData.readShort() - 1; i >= 0; i--)
			{
				tmpArr.push(mData.readUTF());
			}
			return tmpArr;
		}


		protected function readObjectArray(type : Class) : Array
		{
			var tmpArr : Array = [];
			var obj : SNetBaseData;
			for (var i : int = mData.readShort() - 1; i >= 0; i--)
			{
				obj = readObject(type);
				obj && tmpArr.push(obj);
			}
			return tmpArr;
		}

		protected function readByteArray() : Array
		{
			var tmpArr : Array = [];

			for (var i : int = mData.readShort() - 1; i >= 0; i--)
			{
				tmpArr.push(mData.readUnsignedByte());
			}
			return tmpArr;
		}

		protected function readShortArray() : Array
		{
			var tmpArr : Array = [];

			for (var i : int = mData.readShort() - 1; i >= 0; i--)
			{
				tmpArr.push(mData.readUnsignedShort());
			}
			return tmpArr;
		}

		protected function readObject(type : Class) : SNetBaseData
		{
			var obj : SNetBaseData = new type() as SNetBaseData;
			if (obj == null)
				return null;
			obj.deSerialize(mData);
			return obj;
		}

		public function get isDispose() : Boolean
		{
			return false;
		}

		public function dispose() : void
		{
			mData = null;
		}

	}
}