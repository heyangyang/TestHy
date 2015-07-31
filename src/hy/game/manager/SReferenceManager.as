package hy.game.manager
{
	import flash.utils.Dictionary;
	
	import hy.game.aEffect.SEffectAnimationLibrary;
	import hy.game.aEffect.SEffectDescription;
	import hy.game.animation.SAnimationDescription;
	import hy.game.avatar.SAvatarAnimationLibrary;
	import hy.game.avatar.SAvatarDescription;
	import hy.game.cfg.Config;
	import hy.game.core.SReference;
	import hy.game.data.SVersion;
	import hy.game.resources.BytesResource;
	import hy.game.resources.SResource;
	import hy.game.resources.SwfResource;
	import hy.game.sound.SoundReference;
	import hy.rpg.pak.DecoderDirectAnimation;
	import hy.rpg.parser.ParserAnimationResource;
	import hy.rpg.parser.ParserImageResource;
	import hy.rpg.parser.ParserMapResource;
	import hy.rpg.render.SNameParser;

	/**
	 * 游戏中有所实例的管理
	 * 自动 销毁，创建
	 * @author hyy
	 *
	 */
	public class SReferenceManager extends SBaseManager
	{
		private static var instance : SReferenceManager;

		public static function getInstance() : SReferenceManager
		{
			if (instance == null)
				instance = new SReferenceManager();
			return instance;
		}

		public function get status() : String
		{
			var str : String = "";
			if (dic_count[NAME])
				str += "name:" + dic_count[NAME];
			if (dic_count[BITMAPDATA])
				str += "bmd:" + dic_count[BITMAPDATA];
			if (dic_count[PARSER])
				str += "parser:" + dic_count[PARSER];
			return str;
		}

		public static const LOADER : String = "0";
		public static const MAP : String = "1";
		public static const ANIMATION : String = "2";
		public static const ANIMATION_LOAD : String = "3";
		public static const SOUND : String = "4";
		public static const MOVIVE : String = "5";
		public static const ICON : String = "6";
		public static const IMAGE : String = "7";
		public static const FACE : String = "8";
		public static const PARTICLE : String = "9";
		public static const NAME : String = "10";
		public static const PARSER : String = "11";
		public static const BITMAPDATA : String = "12";
		public static const COOL_ANIMATION : String = "13";

		private var check_dic : Dictionary = new Dictionary();
		private var dic : Dictionary = new Dictionary();
		private var dic_count : Dictionary = new Dictionary();
		private var cur_dic : Dictionary;
		private var versionMgr : SVersionManager;
		private var _total_reference : int = 0;

		public function SReferenceManager()
		{
			check_dic[LOADER] = 30;
			check_dic[MAP] = 50;
			check_dic[ANIMATION] = 50;
			check_dic[ANIMATION_LOAD] = 30;
			check_dic[SOUND] = 30;
			check_dic[MOVIVE] = 30;
			check_dic[ICON] = 30;
			check_dic[IMAGE] = 30;
			check_dic[FACE] = 50;
			check_dic[PARTICLE] = 50;
			check_dic[NAME] = 50;
			check_dic[PARSER] = 50;
			check_dic[BITMAPDATA] = 50;
			versionMgr = SVersionManager.getInstance();
		}

		/**
		 * 检测发现可以清理的添加到内存清除列表
		 * @param e
		 *
		 */
		private function onCheckClearMemoryList() : void
		{
			var id : String;
			var reference : SReference;

			for (var key : String in dic)
			{
				cur_dic = dic[key];
				for (id in cur_dic)
				{
					reference = cur_dic[id];
//					if (reference.allowDestroy)
//						memoryMgr.addClearFun(key, id);
				}
			}
		}

		/**
		 * 单个内存清理
		 * @param type
		 * @param id
		 *
		 */
		private function onSingleClearMemory(type : String, id : String) : void
		{
			var clear_dic : Dictionary = dic[type];
			if (clear_dic == null)
				return;
			var reference : SReference = clear_dic[id];
			if (reference)
			{
				reference.tryDestroy();
				if (reference.isDisposed)
				{
					clear_dic[id] = null;
					delete clear_dic[id];
					dic_count[type]--;
					_total_reference--;
				}
			}
		}

		/**
		 * 谨慎使用，一般用于编辑器
		 *
		 */
		public function forceClear(type : String) : void
		{
			var clear_dic : Dictionary = dic[type];
			var reference : SReference;
			for (var id : String in clear_dic)
			{
				reference = clear_dic[id];
				if (reference)
				{
					reference.forceDestroy();
					if (reference.isDisposed)
					{
						clear_dic[id] = null;
						delete clear_dic[id];
					}
				}
			}
		}


		/**
		 * 创建实例
		 * @param type          类型
		 * @param key           id
		 * @param typeClass     类
		 * @param autoDestroy   是否自动销毁
		 * @param args          参数
		 * @return
		 *
		 */
		public function createReference(type : String, key : String, typeClass : Class, ... args) : SReference
		{
			cur_dic = dic[type];
			if (cur_dic == null)
			{
				cur_dic = new Dictionary();
				dic[type] = cur_dic;
				dic_count[type] = 0;
			}
			var reference : SReference = cur_dic[key];
			if (reference && reference.isDisposed)
			{
				error("createReference isDisposed:" + key);
				return null;
			}

			if (!reference)
			{
				var len : int = args.length;
				switch (len)
				{
					case 0:
						reference = new typeClass();
						break;
					case 1:
						reference = new typeClass(args[0]);
						break;
					case 2:
						reference = new typeClass(args[0], args[1]);
						break;
					case 3:
						reference = new typeClass(args[0], args[1], args[2]);
						break;
					case 4:
						reference = new typeClass(args[0], args[1], args[2], args[3]);
						break;
					case 5:
						reference = new typeClass(args[0], args[1], args[2], args[3], args[4]);
						break;
					case 6:
						reference = new typeClass(args[0], args[1], args[2], args[3], args[4], args[5]);
						break;
					case 7:
						reference = new typeClass(args[0], args[1], args[2], args[3], args[4], args[5], args[6]);
						break;
					case 8:
						reference = new typeClass(args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7]);
						break;
					default:
						error("reference 类型不足");
						break;
				}
				cur_dic[key] = reference;
				_total_reference++;
				dic_count[type]++;
			}
			else
			{
				reference.retain();
			}
			return reference;
		}

		public function getReferencesByType(type : String) : Dictionary
		{
			return dic[type];
		}

		public function getReference(type : String, key : String) : SReference
		{
			cur_dic = dic[type];
			if (cur_dic == null)
				return null;
			return cur_dic[key];
		}



		//*********************************加载器****************************
		/**
		 * 创建资源
		 * @param id
		 * @param root
		 * @param context
		 * @param isLocalFile
		 * @return
		 *
		 */
		public function createResource(id : String, v : String = null, root : String = null) : SResource
		{
			if (!id)
				return null;

			id = id.replace(/\\/g, "/");
			//如果没有则需要初始化
			var isInit : Boolean = getReference(LOADER, id) == null;
			var resClass : Class = BytesResource;
			if (isInit)
			{
				if (root == null)
					root = Config.webRoot + "/";
				else
					root = root + "/";
				var version : SVersion = versionMgr.getVersionById(id);
				if (version)
				{
					switch (version.type)
					{
						case 0:
							resClass = SwfResource;
							break;
						case 1:
							break;
					}
					root += version.url;
					v = version.version;
				}
				else
				{
					!v && waring("not find version:" + id);
					root += id;
				}
				root = root.replace(/\\/g, "/");
				print("create resource:" + root);

				//调试模式无视版本号
				if (Config.isDebug)
					v = Math.random() + "";
			}
			var res : SResource = createReference(LOADER, id, resClass, root, v) as SResource;
			res.release();
			return res;
		}

		public function getResource(id : String) : SResource
		{
			if (!id)
				return null;
			id = id.replace(/\\/g, "/");
			return getReference(LOADER, id) as SResource;
		}

		public function clearResource(id : String) : void
		{
			onSingleClearMemory(LOADER, id);
		}

		public function get total_reference() : int
		{
			return _total_reference;
		}

		//*********************************加载器****************************


		//*********************************声音****************************
		public function createSoundReference(id : String) : SoundReference
		{
			return createReference(SOUND, id, SoundReference) as SoundReference;
		}

		public function getSoundReference(id : String) : SoundReference
		{
			return getReference(SOUND, id) as SoundReference;
		}

		//*********************************声音****************************

		//*********************************avatar帧****************************
		public function createAvatarCollection(priority : int, partName : String, avatarDesc : SAvatarDescription, needReversal : Boolean) : SAvatarAnimationLibrary
		{
			if (avatarDesc == null)
				return null;
			return createReference(ANIMATION, partName + "," + avatarDesc.name, SAvatarAnimationLibrary, priority, partName, avatarDesc, needReversal) as SAvatarAnimationLibrary;
		}

		//*********************************avatar帧****************************

		//*********************************动画解析器****************************
		public function createDirectAnimationDeocder(id : String) : DecoderDirectAnimation
		{
			return createReference(PARSER, id, DecoderDirectAnimation, id) as DecoderDirectAnimation;
		}

		//*********************************动画解析器****************************

		//*********************************懒加载动画****************************
		public function createAnimationResourceParser(desc : SAnimationDescription, prioprty : int) : ParserAnimationResource
		{
			return createReference(ANIMATION_LOAD, desc.id, ParserAnimationResource, desc, prioprty) as ParserAnimationResource;
		}

		//*********************************懒加载动画****************************

		//*********************************image****************************
		public function createImageParser(id : String, version : String, priority : int = int.MIN_VALUE) : ParserImageResource
		{
			return createReference(IMAGE, id, ParserImageResource, id, version, priority) as ParserImageResource;
		}

		//*********************************image****************************

		//*********************************特效帧****************************
		public function createEffectCollection(effectDesc : SEffectDescription, needReversal : Boolean) : SEffectAnimationLibrary
		{
			if (effectDesc == null)
				return null;
			return createReference(ANIMATION, effectDesc.id, SEffectAnimationLibrary, effectDesc, needReversal) as SEffectAnimationLibrary;
		}
		
		//*********************************特效帧****************************
		
		//*********************************地图****************************
		public function createMapResourceParser(parserClass : Class, id : String, resId : String, prioprty : int, version : String = null) : ParserMapResource
		{
			return createReference(MAP, id, parserClass, resId, version, prioprty) as ParserMapResource;
		}

		//*********************************地图****************************

		//*********************************名字****************************
		public function createRoleName(name : String, nameTextFontSize : int = 13, nameTextColor : uint = 0xffffff) : SNameParser
		{
			return createReference(NAME, name + "." + nameTextColor, SNameParser, name, nameTextFontSize, nameTextColor) as SNameParser;
		}

		//*********************************名字****************************
	}
}