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

	import hy.game.namespaces.name_part;
	import hy.game.stage3D.display.SImage;
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
	public class SRenderSupport
	{
		private static const QUAD_PROGRAM_NAME : String = "HY_q";
		private static var sProgramNameCache : Dictionary = new Dictionary();
		private static var sContextData : Dictionary = new Dictionary(true);
		private static var sAssembler : AGALMiniAssembler = new AGALMiniAssembler();
		private static var sRenderAlpha : Vector.<Number> = new <Number>[1.0, 1.0, 1.0, 0.5, 1.0, 1.0, 1.0, 0.5, 1.0, 1.0, 1.0, .5, 1.0, 1.0, 1.0, .5];
		private static var sMatrixData : Vector.<Number> = new <Number>[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
		private static var sPoint3D : Vector3D = new Vector3D();
		private static var sCurProgram : Program3D;
		private static var sCurAlpha : Number;
		name_part static var sContext : Context3D;
		private static var sProjectionMatrix3D : Matrix3D;
		private static var sProjectionMatrix : Matrix;
		private static var sVertexBuffer : VertexBuffer3D;
		private static var sIndexBuffer : IndexBuffer3D;
		private static var sMeshIndexData : Vector.<uint>;

		public function SRenderSupport()
		{
		}

		public static function supportImage(image : SImage) : void
		{
			setAlpha(image.alpha);
			setBlendFactors(!image.tinted, image.blendMode);
			//透明度
			sContext.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 0, sRenderAlpha);
			//投影矩阵
			sContext.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 1, sProjectionMatrix3D, true);
			//创建网格
			createVertexBuffer(image.rawData);
			//xy坐标
			sContext.setVertexBufferAt(0, sVertexBuffer, SVertexData.POSITION_OFFSET, Context3DVertexBufferFormat.FLOAT_2);
			//uv坐标
			sContext.setVertexBufferAt(2, sVertexBuffer, SVertexData.TEXCOORD_OFFSET, Context3DVertexBufferFormat.FLOAT_2);
			//纹理
			sContext.setTextureAt(0, image.texture.base);
			createMeshIndexBuffer();

		}

		/**
		 * 创建网格
		 * @param mRawData
		 * @return
		 *
		 */
		public static function createVertexBuffer(mRawData : Vector.<Number>) : VertexBuffer3D
		{
			if (sVertexBuffer == null)
				sVertexBuffer = sContext.createVertexBuffer(mRawData.length / SVertexData.ELEMENTS_PER_VERTEX, SVertexData.ELEMENTS_PER_VERTEX);
			sVertexBuffer.uploadFromVector(mRawData, 0, mRawData.length / SVertexData.ELEMENTS_PER_VERTEX);
			return sVertexBuffer;
		}

		public static function createMeshIndexBuffer() : VertexBuffer3D
		{
			if (sMeshIndexData == null)
			{
				sMeshIndexData = new <uint>[0, 1, 2, 1, 3, 2];
				sIndexBuffer = sContext.createIndexBuffer(sMeshIndexData.length);
				sIndexBuffer.uploadFromVector(sMeshIndexData, 0, sMeshIndexData.length);
			}
			sContext.drawTriangles(sIndexBuffer, 0, 2);
			return null;
		}

		/**
		 * 设置透明度
		 * @param alpha
		 *
		 */
		private static function setAlpha(alpha : Number) : void
		{
			if (sCurAlpha == alpha)
				return;
			sCurAlpha = alpha;
			sRenderAlpha[3] = sRenderAlpha[7] = sRenderAlpha[11] = sRenderAlpha[15] = sCurAlpha;
		}

		/**
		 * 更新着色器
		 * @param texture
		 * @param tinted
		 * @param smoothing
		 *
		 */
		public static function updateProgram(texture : STexture, tinted : Boolean, smoothing : String) : void
		{
			var program : Program3D = getProgram(texture, tinted, smoothing);
			if (sCurProgram == program)
				return;
			sCurProgram = program;
			sContext.setProgram(sCurProgram);
		}

		/**
		 * 根据纹理，是否透明，和平滑度 获取着色器
		 * @param texture
		 * @param tinted
		 * @param smoothing
		 * @return
		 *
		 */
		private static function getProgram(texture : STexture, tinted : Boolean, smoothing : String) : Program3D
		{
			var programName : String = QUAD_PROGRAM_NAME;

			if (texture)
				programName = getImageProgramName(tinted, texture.mipMapping, texture.repeat, texture.format, smoothing);

			var program : Program3D = sContextData[programName];

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
		public static function setBlendFactors(premultipliedAlpha : Boolean, blendMode : String = "normal") : void
		{
			if (blendMode == SBlendMode.AUTO)
				blendMode = SBlendMode.NORMAL;
			var blendFactors : Array = SBlendMode.getBlendFactors(blendMode, premultipliedAlpha);
			sContext.setBlendFactors(blendFactors[0], blendFactors[1]);
		}

		/**
		 * 删除着色器
		 * @param name
		 *
		 */
		public static function deleteProgram(name : String) : void
		{
			var program : Program3D = sContextData[name];
			if (program)
			{
				program.dispose();
				delete sContextData[name];
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
		public static function registerProgramFromSource(name : String, vertexShader : String, fragmentShader : String) : Program3D
		{
			deleteProgram(name);
			var program : Program3D = assembleAgal(vertexShader, fragmentShader);
			sContextData[name] = program;
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
		private static function assembleAgal(vertexShader : String, fragmentShader : String, resultProgram : Program3D = null) : Program3D
		{
			if (resultProgram == null)
			{
				var context : Context3D = SStage3D.context;
				if (context == null)
					throw new MissingContextError();
				resultProgram = context.createProgram();
			}

			resultProgram.upload(sAssembler.assemble(Context3DProgramType.VERTEX, vertexShader), sAssembler.assemble(Context3DProgramType.FRAGMENT, fragmentShader));
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
		public static function getTextureLookupFlags(format : String, mipMapping : Boolean, repeat : Boolean = false, smoothing : String = "bilinear") : String
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

		private static function getImageProgramName(tinted : Boolean, mipMap : Boolean = true, repeat : Boolean = false, format : String = "bgra", smoothing : String = "bilinear") : String
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

			var name : String = sProgramNameCache[bitField];

			if (name == null)
			{
				name = "QB_i." + bitField.toString(16);
				sProgramNameCache[bitField] = name;
			}

			return name;
		}


		public static function setProjectionMatrix(x : Number, y : Number, width : Number, height : Number, stageWidth : Number = 0, stageHeight : Number = 0, cameraPos : Vector3D = null) : void
		{
			if (cameraPos == null)
			{
				cameraPos = sPoint3D;
				cameraPos.setTo(stageWidth / 2, stageHeight / 2, // -> center of stage
					stageWidth / Math.tan(0.5) * 0.5); // -> fieldOfView = 1.0 rad
			}
			sProjectionMatrix = new Matrix();
			// set up 2d (orthographic) projection
			sProjectionMatrix.setTo(2.0 / width, 0, 0, -2.0 / height, -(2 * x + width) / width, (2 * y + height) / height);

			var focalLength : Number = Math.abs(cameraPos.z);
			var offsetX : Number = cameraPos.x - stageWidth / 2;
			var offsetY : Number = cameraPos.y - stageHeight / 2;
			var far : Number = focalLength * 20;
			var near : Number = 1;
			var scaleX : Number = stageWidth / width;
			var scaleY : Number = stageHeight / height;

			// set up general perspective
			sMatrixData[0] = 2 * focalLength / stageWidth; // 0,0
			sMatrixData[5] = -2 * focalLength / stageHeight; // 1,1  [negative to invert y-axis]
			sMatrixData[10] = far / (far - near); // 2,2
			sMatrixData[14] = -far * near / (far - near); // 2,3
			sMatrixData[11] = 1; // 3,2
			//			
			//			// now zoom in to visible area
			sMatrixData[0] *= scaleX;
			sMatrixData[5] *= scaleY;
			sMatrixData[8] = scaleX - 1 - 2 * scaleX * (x - offsetX) / stageWidth;
			sMatrixData[9] = -scaleY + 1 + 2 * scaleY * (y - offsetY) / stageHeight;

			sProjectionMatrix3D = new Matrix3D();
			sProjectionMatrix3D.copyRawDataFrom(sMatrixData);
			sProjectionMatrix3D.prependTranslation(-stageWidth / 2.0 - offsetX, -stageHeight / 2.0 - offsetY, focalLength);
		}
	}
}