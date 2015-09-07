package hy.game.render
{
	import flash.geom.ColorTransform;

	import hy.game.interfaces.display.IBitmap;
	import hy.game.interfaces.display.IBitmapData;
	import hy.game.namespaces.name_part;
	import hy.game.stage3D.STextureSupport;
	import hy.game.stage3D.display.SImage;
	import hy.game.stage3D.texture.STexture;

	use namespace name_part;

	public class SDirectBitmap extends SImage implements IBitmap
	{
		private var mFilters : Vector.<Number>;
		/**
		 * 深度+层级+mId ，用于深度排序
		 * mId防止同一深度，层级混乱排序
		 */
		private var mIndex : int;
		/**
		 * 深度
		 */
		private var mDepth : int;

		public function SDirectBitmap(texture : SDirectBitmapData = null)
		{
			super(texture);
		}

		public override function render() : void
		{
			if (mTexture == null || mTexture.base == null)
				return;
			if (mOrientationChanged)
			{
				isChange = scaleX != 1.0 || rotation != 0.0;
				mOrientationChanged = false;
			}
			STextureSupport.getInstance().supportImage(this);
		}

		public function set data(value : IBitmapData) : void
		{
			if (mTexture != value)
			{
				this.texture = value as STexture;
			}
		}

		public function get data() : IBitmapData
		{
			return texture as IBitmapData;
		}

		public function set colorFilter(value : *) : void
		{
			mFilters = value;
		}

		public function get colorFilter() : *
		{
			return mFilters;
		}

		public function set colorTransform(value : ColorTransform) : void
		{

		}

		public function get colorTransform() : ColorTransform
		{
			return null;
		}
		
		public override function get layer() : int
		{
			return mIndex;
		}

		public override function set layer(value : int) : void
		{
			if (mLayer == value)
				return;
			mLayer = value;
			mIndex = mDepth + mLayer;
			mParent && mParent.addDisplay(this);
		}

		/**
		 * 深度，一般设置为场景坐标
		 * @param value
		 *
		 */
		public function set depth(value : int) : void
		{
			if (mDepth == value)
				return;
			mDepth = value;
			mIndex = mDepth + mLayer;
			mParent && mParent.addDisplay(this);
		}

		public function get depth() : int
		{
			return mDepth;
		}

		public override function dispose() : void
		{
			super.dispose();
			mFilters = null;
		}

	}
}