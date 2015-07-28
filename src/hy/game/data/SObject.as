package hy.game.data
{
	import hy.game.utils.SDebug;

	/**
	 * 所有数据需要继承该类 
	 * @author hyy
	 * 
	 */
	public class SObject
	{
		public function SObject()
		{
		}


		protected function print(... args) : void
		{
			SDebug.print.apply(this, args);
		}
		
		protected function warning(... args) : void
		{
			SDebug.warning.apply(this, args);
		}
		
		protected function error(... args) : void
		{
			SDebug.error.apply(this, args);
		}
	}
}