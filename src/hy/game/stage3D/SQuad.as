package hy.game.stage3D
{
	import hy.game.stage3D.utils.SVertexData;

	public class SQuad extends SDisplayObject
	{
		private var mTinted : Boolean;
		protected var mVertexData : SVertexData;

		public function SQuad(width : Number, height : Number, color : uint = 0xffffff, premultipliedAlpha : Boolean = true)
		{
			super();
			mVertexData = new SVertexData(4, premultipliedAlpha);
			setSize(width, height);
			this.color = color;
		}


		public function setSize(width : Number, height : Number) : void
		{
			mVertexData.setPosition(0, 0.0, 0.0);
			mVertexData.setPosition(1, width, 0.0);
			mVertexData.setPosition(2, width, height);
			mVertexData.setPosition(3, 0.0, height);
		}

		protected function onVertexDataChanged() : void
		{
		}

		public function get color() : uint
		{
			return mVertexData.getColor(0);
		}

		public function set color(value : uint) : void
		{
			mVertexData.setUniformColor(value);
			onVertexDataChanged();

			if (value != 0xffffff || alpha != 1.0)
				mTinted = true;
			else
				mTinted = mVertexData.tinted;
		}

		public override function set alpha(value : Number) : void
		{
			mVertexData.setUniformAlpha(value);
			super.alpha = value;

			if (value < 1.0)
				mTinted = true;
			else
				mTinted = mVertexData.tinted;
		}

		public override function render() : void
		{

		}

		public function get tinted() : Boolean
		{
			return mTinted;
		}

		public function get premultipliedAlpha() : Boolean
		{
			return mVertexData.premultipliedAlpha;
		}
	}
}