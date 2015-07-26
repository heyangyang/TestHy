package hy.game.png
{
	import flash.display.BitmapData;
	import flash.utils.ByteArray;

	public class SPngDecoder
	{
		public function decode(bytes : ByteArray) : BitmapData
		{
			if (!bytes)
				return null;
			bytes.position = 16;
			var width : int = bytes.readInt();
			var height : int = bytes.readInt();
			var transparent : Boolean = bytes.readShort() == 0x806;
			var bitmapData : BitmapData = new BitmapData(width, height, transparent);
			var vector : Vector.<uint> = new Vector.<uint>(width * height, true);
			for (bytes.position = 33; bytes.bytesAvailable > 0; )
			{
				var length : int = bytes.readInt();
				if (bytes.readUTFBytes(4) == "IDAT")
				{
					var bpp : int = transparent ? 4 : 3;
					var data : ByteArray = new ByteArray();
					bytes.readBytes(data, 0, length);
					data.uncompress();

					var bytesPerRow : int = (8 * bpp * width + 7) / 8;
					var rowSize : int = bytesPerRow + bpp;
					var cur : ByteArray = new ByteArray();
					var prev : ByteArray = new ByteArray();
					var i : int, x : int, y : int, xc : int, xp : int;
					var a : int, r : int, g : int, b : int;
					for (i = y = 0; y < height; y++)
					{
						var filterType : int = data.readByte();
						data.readBytes(cur, bpp, bytesPerRow);
						switch (filterType)
						{
							case 0:
							{
								break;
							}
							case 1:
							{
								for (xc = bpp, xp = 0; xc < rowSize; xc++, xp++)
								{
									cur[xc] = cur[xc] + cur[xp];
								}
								break;
							}
							case 2:
							{
								for (xc = bpp; xc < rowSize; xc++)
								{
									cur[xc] = cur[xc] + prev[xc];
								}
								break;
							}
							case 3:
							{
								for (xc = bpp, xp = 0; xc < rowSize; xc++, xp++)
								{
									cur[xc] = cur[xc] + (cur[xp] + prev[xc]) / 2;
								}
								break;
							}
							case 4:
							{
								for (xc = bpp, xp = 0; xc < rowSize; xc++, xp++)
								{
									var ca : int = cur[xp];
									var cb : int = prev[xc];
									var cc : int = prev[xp];
									var cd : int = ca + cb - cc;
									var pa : int = cd - ca;
									if (pa < 0)
										pa = -pa;
									var pb : int = cd - cb;
									if (pb < 0)
										pb = -pb;
									var pc : int = cd - cc;
									if (pc < 0)
										pc = -pc;
									if (pa <= pb && pa <= pc)
										cd = ca;
									else if (pb <= pc)
										cd = cb;
									else
										cd = cc;
									cur[xc] = cur[xc] + cd;
								}
								break;
							}
						}
						if (transparent)
						{
							for (x = 0; x < width; x++)
							{
								a = cur[x * 4 + 7];
								r = cur[x * 4 + 4];
								g = cur[x * 4 + 5];
								b = cur[x * 4 + 6];
								vector[i++] = a << 24 | r << 16 | g << 8 | b;
							}
						}
						else
						{
							for (x = 0; x < width; x++)
							{
								r = cur[x * 3 + 3];
								g = cur[x * 3 + 4];
								b = cur[x * 3 + 5];
								vector[i++] = r << 16 | g << 8 | b;
							}
						}
						var tmp : ByteArray = cur;
						cur = prev;
						prev = tmp;
					}
				}
				else
				{
					bytes.position += length + 4;
				}
			}
			bitmapData.setVector(bitmapData.rect, vector);
			return bitmapData;
		}
	}
}