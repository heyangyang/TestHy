package starling.base
{


	/**
	 * 启动类
	 * @author Administrator
	 *
	 */
	public class Game3D extends SSprite
	{
		public static var stage3D : Game3D;

		public function Game3D()
		{
			super();
		}

		public function start() : void
		{
			stage3D = this;
		}

	}
}