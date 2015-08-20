package hy.game.stage3D.display
{
	import flash.geom.Matrix;

	import hy.game.stage3D.utils.SVertexData;

	public class SQuad extends SDisplayObject
	{
		private var mTinted : Boolean;
		private var mColor : uint;
		protected var mVertexData : SVertexData;

		public function SQuad(width : Number, height : Number, color : uint = 0xffffff, premultipliedAlpha : Boolean = true)
		{
			super();
			mTinted = color != 0xffffff;
			mVertexData = new SVertexData(4);
			setSize(width, height);
			//this.color = color;
		}


		public function setSize(width : Number, height : Number) : void
		{
			mVertexData.setPosition(0, 0.0, 0.0);
			mVertexData.setPosition(1, width, 0.0);
			mVertexData.setPosition(2, 0.0, height);
			mVertexData.setPosition(3, width, height);
		}

		protected function onVertexDataChanged() : void
		{
		}

		public function get color() : uint
		{
			return mColor;
		}

		public function set color(value : uint) : void
		{
			mColor = value;
			onVertexDataChanged();

			if (value != 0xffffff || alpha != 1.0)
				mTinted = true;
			else
				mTinted = false;
		}

		public override function set alpha(value : Number) : void
		{
			super.alpha = value;
			if (value < 1.0)
				mTinted = true;
			else
				mTinted = false;
		}

		public function copyVertexDataTransformedTo(targetData : SVertexData, matrix : Matrix = null) : void
		{
			mVertexData.copyTransformedTo(targetData, 0, matrix, 0, 4);
		}

		public override function render() : void
		{

		}

		public function get tinted() : Boolean
		{
			return mTinted;
		}

		public function get rawData() : Vector.<Number>
		{
			return mVertexData.rawData;
		}
	}
}