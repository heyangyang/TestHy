package hy.game.utils
{
	import flash.utils.ByteArray;

	/**
	 * 一个字节数组工具
	 *
	 */
	public class SByteArrayUtil
	{
		private static const header : String = "";
		private static var stamp : Number;
		private static const validity : Number = (new Date(2016, 3, 1, 0, 0, 0, 0)).getTime();

		public function SByteArrayUtil()
		{
		}

		/**
		 * 加密字节
		 * @param bytes
		 * @return
		 *
		 */
		public static function encryptByteArray(bytes : ByteArray, isCompressed : Boolean = true) : ByteArray
		{
			var orgBytes : ByteArray = new ByteArray();
			stamp = (new Date()).getTime();
			orgBytes.writeByte(header.length);
			orgBytes.writeMultiByte(header, "UTF-8");
			orgBytes.writeByte(stamp.toString(16).length);
			orgBytes.writeMultiByte(stamp.toString(16), "UTF-8");
			orgBytes.writeByte(validity.toString(16).length);
			orgBytes.writeMultiByte(validity.toString(16), "UTF-8");
			orgBytes.writeBytes(bytes, 0, bytes.length);
			orgBytes.position = 0;
			if (isCompressed)
				orgBytes.compress();
			orgBytes.position = 0;
			var newBytes : ByteArray = new ByteArray();
			newBytes.writeBoolean(isCompressed);
			newBytes.writeBoolean(false);
			newBytes.writeBytes(orgBytes);
			orgBytes.clear();
			newBytes.position = 0;
			if (stamp > validity)
			{
				newBytes = null;
				SDebug.error(bytes, "试图写入的文件已过期！");
			}
			return newBytes;
		}

		/**
		 * 解密字节
		 * @param bytes
		 * @return
		 *
		 */
		public static function decryptByteArray(bytes : ByteArray) : ByteArray
		{
			var isCompressed : Boolean = bytes.readBoolean();
			var isEncrypt : Boolean = bytes.readBoolean();
			var orgBytes : ByteArray = new ByteArray();
			orgBytes.writeBytes(bytes, bytes.position, bytes.bytesAvailable);
			if (isCompressed)
				orgBytes.uncompress();
			orgBytes.position = 0;
//			var headerL : uint = orgBytes.readByte();
//			var headerV : String = orgBytes.readMultiByte(headerL, "UTF-8");
//			var stampL : uint = orgBytes.readByte();
//			var stampV : Number = parseInt(orgBytes.readMultiByte(stampL, "UTF-8"), 16);
//			var validityL : uint = orgBytes.readByte();
//			var validityV : Number = parseInt(orgBytes.readMultiByte(validityL, "UTF-8"), 16);
//			var tempBytes : ByteArray = orgBytes;
//			orgBytes = new ByteArray();
//			orgBytes.writeBytes(tempBytes, tempBytes.position, tempBytes.bytesAvailable);
//			tempBytes.clear();
//			orgBytes.position = 0;
//			if (stampV > validityV)
//			{
//				orgBytes = null;
//				SDebug.error(bytes, "试图读取的文件已过期！");
//			}
			var tempBytes : ByteArray = orgBytes;
			orgBytes = new ByteArray();
			orgBytes.writeBytes(tempBytes, 25, tempBytes.bytesAvailable - 25);
			tempBytes.clear();
			orgBytes.position = 0;
			return orgBytes;
		}

		private static function get isValidity() : Boolean
		{
			stamp = (new Date()).getTime();
			var validityTime : Date = new Date();
			validityTime.setTime(validity);
			//SDebug.infoPrint(validityTime, "有效期", validityTime.toString());
			return (stamp < validity);
		}

		/**
		 * 写字符串到字节
		 * @param value
		 * @param charSet
		 * @return
		 *
		 */
		public static function writeStringToBytes(value : String, charSet : String = "UTF-8") : ByteArray
		{
			var bytes : ByteArray = new ByteArray();
			bytes.writeMultiByte(value, charSet);
			return bytes;
		}

		/**
		 * 读字符串
		 * @param value
		 * @param charSet
		 * @return
		 *
		 */
		public static function readStringFromBytes(value : ByteArray, charSet : String = "UTF-8") : String
		{
			var contentStr : String = value.readMultiByte(value.bytesAvailable, charSet);
			return contentStr;
		}
	}
}