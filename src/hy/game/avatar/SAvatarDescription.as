package hy.game.avatar
{
	import flash.utils.Dictionary;
	
	import hy.game.utils.SDebug;
	import hy.rpg.enmu.SDirection;

	/**
	 *
	 * 纸娃娃描述
	 *
	 */
	public class SAvatarDescription
	{
		public var name : String;
		public var version : String;
		/**
		 * 组成部分排序，用于 ComposedAnimation
		 */
		public var partOrder : Array;
		public var width : int;
		public var height : int;
		public var leftBorder : int;
		public var topBorder : int;
		public var rightBorder : int;
		public var bottomBorder : int;

		/**
		 * 由名字可以获得动作描述
		 */
		private var _actionDescByAction : Dictionary;

		/**
		 * 动作拥有的方向
		 */
		public var directions : Array;

		public function SAvatarDescription()
		{
			super();
			_actionDescByAction = new Dictionary();
		}

		/**
		 * 根据部件名称获取部件类型，如body1的部件类型是身体1
		 * @param part
		 * @return
		 */
		public function getPartType(partName : String) : uint
		{
			for each (var actionDesc : SAvatarActionDescription in _actionDescByAction)
			{
				for each (var partDesc : SAvatarPartDescription in actionDesc.partDescByName)
				{
					if (partDesc.id == partName)
					{
						return partDesc.type;
					}
				}
			}
			return 0;
		}

		/**
		 * 根据部件名称获取部件种类
		 * @param part
		 * @return
		 */
		public function getPartKind(partName : String) : uint
		{
			for each (var actionDesc : SAvatarActionDescription in _actionDescByAction)
			{
				for each (var partDesc : SAvatarPartDescription in actionDesc.partDescByName)
				{
					if (partDesc.id == partName)
					{
						return partDesc.kind;
					}
				}
			}
			return 0;
		}

		/**
		 * 获得当前的动作组成部件名字
		 * @return
		 *
		 */
		public function getPartNames() : Array
		{
			var parts : Array = [];
			for each (var actionDesc : SAvatarActionDescription in _actionDescByAction)
			{
				for each (var partDesc : SAvatarPartDescription in actionDesc.partDescByName)
				{
					parts.push(partDesc.id);
				}
				break;
			}
			return parts;
		}

		private function setActionDesc(type : uint, kind : uint, actionDesc : SAvatarActionDescription) : void
		{
			_actionDescByAction[type * 10000 + kind] = actionDesc;
		}

		/**
		 * 每一个动作作为一个avatar，在这里添加多个动作
		 * @param actionXML
		 *
		 */
		public function addActionDesc(actionXML : XML) : void
		{
			var actionDesc : SAvatarActionDescription = new SAvatarActionDescription();
			actionDesc.type = int(actionXML.@type);
			actionDesc.kind = int(actionXML.@kind);
			if (version != "2")
				actionDesc.name = String(actionXML.@name).toLowerCase();
			actionDesc.attackTime = int(actionXML.@attackFrame);
			actionDesc.soundTime = int(actionXML.@soundFrame);

			var animationXml : XML = actionXML.part.animation[0];

			if (animationXml)
			{
				actionDesc.attackStartFrame = int(animationXml.@attackStartFrame);
				actionDesc.attackEndFrame = int(animationXml.@attackEndFrame);
				actionDesc.attackHitFrame = int(animationXml.@attackHitFrame);
				actionDesc.attackMoveFrame = int(animationXml.@attackMoveFrame);
				actionDesc.attackJumpFrame = int(animationXml.@attackJumpFrame);
				actionDesc.attackStartDelay = int(animationXml.@attackStartDelay);
				actionDesc.attackEndDelay = int(animationXml.@attackEndDelay);
			}

			if (version == "2")
			{
				if (!SActionType.getActionNameByType(actionDesc.type))
					SDebug.error("id为" + name + "的角色动作" + actionDesc.type + "类型不正确！");
			}
			else
			{
				if (SActionType.getActionTypeByName(actionDesc.name) != actionDesc.type)
					SDebug.error("id为" + name + "的角色动作" + actionDesc.name + "类型不正确！");
			}

			var dirs : String = String(actionXML.@directions);
			var actionDirections : Array = dirs ? getDirections(dirs) : null;
			if (version != "2")
			{
				directions = getDirections(dirs);
			}
			actionDesc.directions = (actionDirections || directions);

			actionDesc.setJumpFrames(actionXML.@jumpFrames);
			actionDesc.setFlightFrames(actionXML.@flightFrames);
			actionDesc.setSectionJumpFrames(actionXML.@sectionJumpFrames);
			actionDesc.setJumpLandFrames(actionXML.@jumpLandFrames);

			//
			//				actionDesc.order = String(actionXML.@order)? String(actionXML.@order).split(','):null;
			setActionDesc(actionDesc.type, actionDesc.kind, actionDesc);

			for each (var partXML : XML in actionXML.part)
			{
				var partType : uint = int(partXML.@type);
				var partKind : uint = int(partXML.@kind);
				var partName : String = String(partXML.@name);

				var partDesc : SAvatarPartDescription = new SAvatarPartDescription();
				partDesc.type = partType;
				if (version == "2")
				{
					partDesc.kind = partKind;
					partDesc.id = SAvatarPartType.getPartNameByType(partDesc.type) + partDesc.kind;
				}
				else
					partDesc.id = String(partKind);

				for each (var dir : int in actionDesc.directions)
				{
					if (version == "2")
					{
						var animKind : uint = uint(partDesc.kind);
						var copyKind : String = String(partXML.@copy);
						if (copyKind)
							animKind = uint(copyKind);
						partDesc.addAnimationIdByDir(dir, getAnimationId(name, partDesc.type, animKind, actionDesc.type, actionDesc.kind, dir));
					}
					else
						SDebug.error(this);
//						partDesc.addAnimationIdByDir(dir, SPrintf.printf('$avatarId$/$partType$/$partName$/$action$/$dir$', name, partName, partDesc.id, actionDesc.name, dir));
				}
				actionDesc.partDescByName[partDesc.id] = partDesc;
				partDesc.directions = actionDesc.directions;
			}
		}

		private function getAnimationId(avatarId : String, part : uint, kind : uint, action : uint, actionKind : uint, direction : uint) : String
		{
			return "avatar." + avatarId + "." + part + "." + kind + "." + action + "." + actionKind + "." + direction;
		}

		private function getDirections(dirs : String) : Array
		{
			var result : Array;
			if (!dirs)
				result = [SDirection.EAST, SDirection.NORTH, SDirection.SOUTH, SDirection.WEST, SDirection.EAST_NORTH, SDirection.WEST_NORTH, SDirection.EAST_SOUTH, SDirection.WEST_SOUTH];
			else
			{
				result = dirs.split(",");
				for (var i : int = result.length - 1; i >= 0; i--)
				{
					result[i] = int(result[i]);
				}
			}
			return result;
		}

		public function setDirections(dirs : String) : void
		{
			directions = getDirections(dirs);
		}

		public function getActionDescByAction(action : uint, kind : uint) : SAvatarActionDescription
		{
			return _actionDescByAction[action * 10000 + kind];
		}

		/**
		 * 得到一个有效动作
		 * @return
		 */
		public function getAvaliableAction() : Array
		{
			for each (var actionDesc : SAvatarActionDescription in _actionDescByAction)
			{
				return [actionDesc.type, actionDesc.kind];
			}
			return null;
		}

		public function getAvaliableActionByType(action : int) : Array
		{
			for each (var actionDesc : SAvatarActionDescription in _actionDescByAction)
			{
				if (actionDesc.type == action)
					return [actionDesc.type, actionDesc.kind];
			}
			return null;
		}

		/**
		 * 得到一个有效部件
		 * @return
		 *
		 */
		public function getAvaliableParts() : Array
		{
			return getPartNames();
		}

		public function get actionDescByActionMap() : Dictionary
		{
			return _actionDescByAction;
		}
	}
}