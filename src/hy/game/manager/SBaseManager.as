package hy.game.manager
{
	import hy.game.utils.SDebug;

	public class SBaseManager
	{
		public function SBaseManager()
		{
		}

		public function print(... args) : void
		{
			SDebug.print(args.join(","));
		}

		public function waring(... args) : void
		{
			SDebug.warning(args.join(","));
		}

		public function error(... args) : void
		{
			SDebug.error(args.join(","));
		}
	}
}