package hy.game.aEffect
{
	import flash.utils.Dictionary;
	
	import hy.game.data.SObject;
	import hy.rpg.enum.EnumDirection;
	import hy.game.animation.SAnimationManager;

	/**
	 * 特效描述
	 *
	 */
	public class SEffectDescription extends SObject
	{
		public var version : String;
		/**
		 * 动画所有方向
		 */
		public var animationDirections : Array;
		public var width : int;
		public var height : int;
		public var leftBorder : int;
		public var topBorder : int;
		public var rightBorder : int;
		public var bottomBorder : int;

		/**
		 * 动画的id
		 */
		public var id : String;

		/**
		 * 动作拥有的方向
		 */
		public var directions : Array = [EnumDirection.EAST];

		/**
		 * 由方向记录的动画id，即可以根据一个方向得到一个动画的id
		 */
		private var _animationIdByDir : Dictionary;

		public function SEffectDescription()
		{
			super();
			_animationIdByDir = new Dictionary();
			animationDirections = [];
		}

		public function setDirections(dirs : String) : void
		{
			if (version == "2")
			{
				if (!dirs)
					directions = [EnumDirection.EAST, EnumDirection.NORTH, EnumDirection.SOUTH, EnumDirection.WEST, EnumDirection.EAST_NORTH, EnumDirection.WEST_NORTH, EnumDirection.EAST_SOUTH, EnumDirection.WEST_SOUTH];
				else
				{
					directions = dirs.split(",");
					for (var i : int = directions.length - 1; i >= 0; i--)
					{
						directions[i] = int(directions[i]);
					}
				}
			}
			for each (var dir : int in directions)
			{
				if (version == "2")
					addAnimationIdByDir(dir, getAnimationId(id, dir));
				else
					addAnimationIdByDir(dir, id);
			}
		}

		public static function getAnimationId(effectId : String, direction : uint) : String
		{
			return "effect." + effectId + "." + direction;
		}

		public static function getAnimationFileName(direction : uint) : String
		{
			var directionName : String = "d" + direction;
			var name : String = directionName;
			return name;
		}

		private static var _effectDescByEffectId : Dictionary = new Dictionary();

		public static function addEffectDescription(id : String, xml : XML, version : String = "0", isReplace : Boolean = false) : SEffectDescription
		{
			if (_effectDescByEffectId[id] == null || isReplace)
			{
				var effectDesc : SEffectDescription = parseEffectDescription(xml, version);
				if (effectDesc)
				{
					_effectDescByEffectId[id] = effectDesc;
				}
				return effectDesc;
			}
			return getEffectDescription(id);
		}

		/**
		 * 解析Parser 特效信息
		 * @param xml
		 * @return
		 *
		 */
		public static function parseEffectDescription(xml : XML, version : String = null) : SEffectDescription
		{
			if (!xml)
				return null;

			var effectDesc : SEffectDescription = new SEffectDescription();
			effectDesc.id = String(xml.@name).toLowerCase();
			effectDesc.version = String(xml.@version);

			effectDesc.width = int(xml.@width);
			effectDesc.height = int(xml.@height);
			effectDesc.leftBorder = int(xml.@leftBorder);
			effectDesc.topBorder = int(xml.@topBorder);
			effectDesc.rightBorder = int(xml.@rightBorder);
			effectDesc.bottomBorder = int(xml.@bottomBorder);
			effectDesc.setDirections(String(xml.@directions));

			var animations : XML = <animations></animations>;
			animations.appendChild(xml.animation);

			//添加动画描述
			SAnimationManager.getInstance().addBatchAnimationDescription(animations, effectDesc.width, effectDesc.height, version);

			return effectDesc;
		}

		public static function getEffectDescription(id : String) : SEffectDescription
		{
			return _effectDescByEffectId[id];
		}

		public static function removeEffectDescription(id : String) : void
		{
			if (_effectDescByEffectId[id])
			{
				_effectDescByEffectId[id] = null;
				delete _effectDescByEffectId[id];
			}
		}


		public function addAnimationIdByDir(dir : uint, id : String) : void
		{
			_animationIdByDir[dir] = id;
		}

		public function getAnimationIdByDir(dir : uint) : String
		{
			var mode : uint = EnumDirection.checkDirsDirMode(directions);
			dir = EnumDirection.correctDirection(mode, dir, dir);
			return _animationIdByDir[dir];
		}

		public function getAvaliableAnimation() : String
		{
			for each (var animationId : String in _animationIdByDir)
			{
				if (animationId)
					return animationId;
			}
			return null;
		}
	}

}