package hy.game.stage3D
{
	import com.adobe.utils.AGALMiniAssembler;
	
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.Program3D;
	import flash.display3D.VertexBuffer3D;
	import flash.geom.Matrix;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	import flash.utils.Dictionary;
	
	import hy.game.manager.SBaseManager;
	import hy.game.namespaces.name_part;
	import hy.game.render.SDirectBitmap;
	import hy.game.stage3D.errors.MissingContextError;
	import hy.game.stage3D.texture.SBlendMode;
	import hy.game.stage3D.texture.STexture;
	import hy.game.stage3D.texture.STextureSmoothing;
	import hy.game.stage3D.utils.SVertexData;

	use namespace name_part;

	/**
	 * 提交纹理
	 * @author hyy
	 *
	 */
	public class SRenderSupport extends SBaseManager
	{
		private static var instance : SRenderSupport;

		public static function getInstance() : SRenderSupport
		{
			if (instance == null)
				instance = new SRenderSupport();
			return instance;
		}
		private static var sDrawCount : int;

		/**
		 * 更新纹理次数
		 * @return
		 *
		 */
		public static function get drawCount() : int
		{
			return sDrawCount
		}

		name_part var mContext : Context3D;
		private const QUAD_PROGRAM_NAME : String = "HY_q";
		private var mProgramNameCache : Dictionary = new Dictionary();
		private var mContextData : Dictionary = new Dictionary(true);
		private var mAssembler : AGALMiniAssembler = new AGALMiniAssembler();
		private var mRenderAlpha : Vector.<Number>;
		private var mRenderAlpha1 : Vector.<Number>;
		private var mMatrixData : Vector.<Number>;
		private var mPoint3D : Vector3D = new Vector3D();
		private var mCurProgram : Program3D;
		private var mCurAlpha : Number;
		private var mProjectionMatrix3D : Matrix3D;
		private var mPositionMatrix3D : Matrix3D;
		private var mProjectionMatrix : Matrix;
		private var mVertexBuffer : VertexBuffer3D;
		private var mIndexBuffer : IndexBuffer3D;
		private var mMeshIndexData : Vector.<uint>;
		private var mUpdateCameraMatrix3D : Boolean;

		public function SRenderSupport()
		{
			if (instance)
				error("instance != null");
			mRenderAlpha = new Vector.<Number>();
			mRenderAlpha.push(1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0);
			mRenderAlpha1 = new Vector.<Number>();
			mRenderAlpha1.push(
				1.4, 1.4,1.4, 1.0, 
				1.4, 1.4,1.4, 1.0, 
				1.4, 1.4,1.4, 1.0, 
				1.4, 1.4,1.4, 1.0);
			mMatrixData = new Vector.<Number>();
			mMatrixData.push(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		}

		public function reset() : void
		{
			sDrawCount = 0;
		}

		public function supportImage(image : SDirectBitmap) : void
		{
			updateProgram(image.texture, image.tinted, image.smoothing);
			//混合模式
			setBlendFactors(!image.tinted, image.blendMode);
			//投影矩阵
			if (mUpdateCameraMatrix3D)
			{
				mUpdateCameraMatrix3D = false;
				mContext.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 1, mProjectionMatrix3D, true);
			}
			mVertexBuffer = image.vertexBuffer3D;
			//xy坐标
			mContext.setVertexBufferAt(0, mVertexBuffer, SVertexData.POSITION_OFFSET, Context3DVertexBufferFormat.FLOAT_2);
			//纹理
			mContext.setTextureAt(0, image.base);
			//uv坐标
			mContext.setVertexBufferAt(2, mVertexBuffer, SVertexData.TEXCOORD_OFFSET, Context3DVertexBufferFormat.FLOAT_2);
			//设置xy
			mPositionMatrix3D.copyFrom(mProjectionMatrix3D);
			mPositionMatrix3D.prependTranslation(image.x, image.y, 0);
			//透明度
			if (image.filters)
				setAlpha(image.alpha, mRenderAlpha1);
			else
				setAlpha(image.alpha, mRenderAlpha);
			mContext.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 1, mPositionMatrix3D, true);
			//创建索引，并且提交索引，开始绘制
			createMeshIndexBuffer();
			sDrawCount++;
		}

		/**
		 * 结束后，检测缓冲区
		 *
		 */
		public function finishDraw() : void
		{
			mVertexBuffer = null;
		}

		/**
		 * 创建索引，并且提交索引
		 * @return
		 *
		 */
		public function createMeshIndexBuffer() : VertexBuffer3D
		{
			if (mMeshIndexData == null)
			{
				mMeshIndexData = new Vector.<uint>();
				mMeshIndexData.push(0, 1, 2, 1, 3, 2);
				mIndexBuffer = mContext.createIndexBuffer(mMeshIndexData.length);
				mIndexBuffer.uploadFromVector(mMeshIndexData, 0, mMeshIndexData.length);
			}
			mContext.drawTriangles(mIndexBuffer, 0, 2);
			return null;
		}

		/**
		 * 设置透明度
		 * @param alpha
		 *
		 */
		private function setAlpha(alpha : Number, alphaArray : Vector.<Number>) : void
		{
//			if (mCurAlpha == alpha)
//				return;
			mCurAlpha = alpha;
			alphaArray[3] = alphaArray[7] = alphaArray[11] = alphaArray[15] = mCurAlpha;
			mContext.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 0, alphaArray);
		}

		/**
		 * 更新着色器
		 * @param texture
		 * @param tinted
		 * @param smoothing
		 *
		 */
		public function updateProgram(texture : STexture, tinted : Boolean, smoothing : String) : void
		{
			var program : Program3D = getProgram(texture, tinted, smoothing);
			if (mCurProgram == program)
				return;
			mCurProgram = program;
			mUpdateCameraMatrix3D = true;
			mContext.setProgram(mCurProgram);
		}

		/**
		 * 根据纹理，是否透明，和平滑度 获取着色器
		 * @param texture
		 * @param tinted
		 * @param smoothing
		 * @return
		 *
		 */
		private function getProgram(texture : STexture, tinted : Boolean, smoothing : String) : Program3D
		{
			var programName : String = QUAD_PROGRAM_NAME;

			if (texture)
				programName = getImageProgramName(tinted, texture.mipMapping, texture.repeat, texture.format, smoothing);

			var program : Program3D = mContextData[programName];

			if (!program)
			{
				// this is the input data we'll pass to the shaders:
				// va0 -> position
				// va1 -> color
				// va2 -> texCoords
				// vc0 -> alpha
				// vc1 -> mvpMatrix
				// fs0 -> texture

				var vertexShader : String;
				var fragmentShader : String;

				if (!texture) // Quad-Shaders
				{
					vertexShader = "m44 op, va0, vc1 \n" // 4x4 matrix transform to output clipspace
						+ "mul v0, va1, vc0 \n"; // multiply alpha (vc0) with color (va1)

					fragmentShader = "mov oc, v0       \n"; // output color
				}
				else // Image-Shaders
				{
					vertexShader = tinted ? "m44 op, va0, vc1 \n" // 4x4 matrix transform to output clipspace
						+ "mov v0, vc0 \n" // multiply alpha (vc0) with color (va1)
						+ "mov v1, va2      \n" // pass texture coordinates to fragment program
						: "m44 op, va0, vc1 \n" + // 4x4 matrix transform to output clipspace
						"mov v1, va2      \n"; // pass texture coordinates to fragment program

					fragmentShader = tinted ? "tex ft1,  v1, fs0 <???> \n" // sample texture 0
						+ "mul  oc, ft1,  v0       \n" // multiply color with texel color
						: "tex  oc,  v1, fs0 <???> \n"; // sample texture 0

					fragmentShader = fragmentShader.replace("<???>", getTextureLookupFlags(texture.format, texture.mipMapping, texture.repeat, smoothing));
				}
				program = registerProgramFromSource(programName, vertexShader, fragmentShader);
			}

			return program;
		}

		/**
		 * 设置混合模式
		 * @param premultipliedAlpha
		 * @param blendMode
		 *
		 */
		private var sPremultipliedAlpha : Boolean;
		private var sBlendMode : String;

		public function setBlendFactors(premultipliedAlpha : Boolean, blendMode : String = "normal") : void
		{
			if (sPremultipliedAlpha == premultipliedAlpha && sBlendMode == blendMode)
				return;
			sBlendMode = blendMode;
			sPremultipliedAlpha == premultipliedAlpha;
			if (blendMode == SBlendMode.AUTO)
				blendMode = SBlendMode.NORMAL;
			var blendFactors : Array = SBlendMode.getBlendFactors(blendMode, premultipliedAlpha);
			mContext.setBlendFactors(blendFactors[0], blendFactors[1]);
		}

		/**
		 * 删除着色器
		 * @param name
		 *
		 */
		public function deleteProgram(name : String) : void
		{
			var program : Program3D = mContextData[name];
			if (program)
			{
				program.dispose();
				delete mContextData[name];
			}
		}

		/**
		 * 保存着色器
		 * @param name
		 * @param vertexShader
		 * @param fragmentShader
		 * @return
		 *
		 */
		public function registerProgramFromSource(name : String, vertexShader : String, fragmentShader : String) : Program3D
		{
			deleteProgram(name);
			var program : Program3D = assembleAgal(vertexShader, fragmentShader);
			mContextData[name] = program;
			return program;
		}

		/**
		 * 提交着色器
		 * @param vertexShader
		 * @param fragmentShader
		 * @param resultProgram
		 * @return
		 *
		 */
		private function assembleAgal(vertexShader : String, fragmentShader : String, resultProgram : Program3D = null) : Program3D
		{
			if (resultProgram == null)
			{
				var context : Context3D = SStage3D.context;
				if (context == null)
					throw new MissingContextError();
				resultProgram = context.createProgram();
			}

			resultProgram.upload(mAssembler.assemble(Context3DProgramType.VERTEX, vertexShader), mAssembler.assemble(Context3DProgramType.FRAGMENT, fragmentShader));
			return resultProgram;
		}

		/**
		 * 设置平滑模式
		 * @param format
		 * @param mipMapping
		 * @param repeat
		 * @param smoothing
		 * @return
		 *
		 */
		public function getTextureLookupFlags(format : String, mipMapping : Boolean, repeat : Boolean = false, smoothing : String = "bilinear") : String
		{
			var options : Array = ["2d", repeat ? "repeat" : "clamp"];

			if (format == Context3DTextureFormat.COMPRESSED)
				options.push("dxt1");
			else if (format == "compressedAlpha")
				options.push("dxt5");

			if (smoothing == STextureSmoothing.NONE)
				options.push("nearest", mipMapping ? "mipnearest" : "mipnone");
			else if (smoothing == STextureSmoothing.BILINEAR)
				options.push("linear", mipMapping ? "mipnearest" : "mipnone");
			else
				options.push("linear", mipMapping ? "miplinear" : "mipnone");
			return "<" + options.join() + ">";
		}

		private function getImageProgramName(tinted : Boolean, mipMap : Boolean = true, repeat : Boolean = false, format : String = "bgra", smoothing : String = "bilinear") : String
		{
			var bitField : uint = 0;

			if (tinted)
				bitField |= 1;
			if (mipMap)
				bitField |= 1 << 1;
			if (repeat)
				bitField |= 1 << 2;

			if (smoothing == STextureSmoothing.NONE)
				bitField |= 1 << 3;
			else if (smoothing == STextureSmoothing.TRILINEAR)
				bitField |= 1 << 4;

			if (format == Context3DTextureFormat.COMPRESSED)
				bitField |= 1 << 5;
			else if (format == "compressedAlpha")
				bitField |= 1 << 6;

			var name : String = mProgramNameCache[bitField];

			if (name == null)
			{
				name = "QB_i." + bitField.toString(16);
				mProgramNameCache[bitField] = name;
			}

			return name;
		}


		public function setProjectionMatrix(x : Number, y : Number, width : Number, height : Number, stageWidth : Number = 0, stageHeight : Number = 0, cameraPos : Vector3D = null) : void
		{
			if (cameraPos == null)
			{
				cameraPos = mPoint3D;
				cameraPos.setTo(stageWidth / 2, stageHeight / 2, // -> center of stage
					stageWidth / Math.tan(0.5) * 0.5); // -> fieldOfView = 1.0 rad
			}
			mProjectionMatrix = new Matrix();
			// set up 2d (orthographic) projection
			mProjectionMatrix.setTo(2.0 / width, 0, 0, -2.0 / height, -(2 * x + width) / width, (2 * y + height) / height);

			var focalLength : Number = Math.abs(cameraPos.z);
			var offsetX : Number = cameraPos.x - stageWidth / 2;
			var offsetY : Number = cameraPos.y - stageHeight / 2;
			var far : Number = focalLength * 20;
			var near : Number = 1;
			var scaleX : Number = stageWidth / width;
			var scaleY : Number = stageHeight / height;

			// set up general perspective
			mMatrixData[0] = 2 * focalLength / stageWidth; // 0,0
			mMatrixData[5] = -2 * focalLength / stageHeight; // 1,1  [negative to invert y-axis]
			mMatrixData[10] = far / (far - near); // 2,2
			mMatrixData[14] = -far * near / (far - near); // 2,3
			mMatrixData[11] = 1; // 3,2
			//			
			//			// now zoom in to visible area
			mMatrixData[0] *= scaleX;
			mMatrixData[5] *= scaleY;
			mMatrixData[8] = scaleX - 1 - 2 * scaleX * (x - offsetX) / stageWidth;
			mMatrixData[9] = -scaleY + 1 + 2 * scaleY * (y - offsetY) / stageHeight;

			mProjectionMatrix3D = new Matrix3D();
			mProjectionMatrix3D.copyRawDataFrom(mMatrixData);
			mProjectionMatrix3D.prependTranslation(-stageWidth / 2.0 - offsetX, -stageHeight / 2.0 - offsetY, focalLength);
			mPositionMatrix3D = new Matrix3D();
			//提交矩阵
			mUpdateCameraMatrix3D = true;
		}
	}
}