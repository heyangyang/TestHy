package hy.game.sound
{

	import flash.media.SoundTransform;
	import flash.system.ApplicationDomain;
	import flash.utils.Dictionary;

	import hy.game.manager.SReferenceManager;

	/**
	 * 音乐管理器
	 * @author yangyang
	 *
	 */
	public class SoundManager
	{
		private static var instance : SoundManager;

		private var bgSoundTransform : SoundTransform;
		private var effectSoundTransform : SoundTransform;

		private var soundClassDatas : Dictionary = new Dictionary();

		private var m_isOpenEffectSound : Boolean;
		private var m_isOpenBgSound : Boolean;
		/**
		 * 播放背景音乐
		 * 如果是关闭背景音乐状态，则暂停播放。
		 * @param soundID
		 */
		private var m_bgSoundId : String;
		private var m_bgSound : SoundReference;

		public static function getInstance() : SoundManager
		{
			if (instance == null)
			{
				instance = new SoundManager();
			}
			return instance;
		}

		public function SoundManager()
		{
			bgSoundTransform = new SoundTransform();
			effectSoundTransform = new SoundTransform();
		}


		/**
		 * 播放一个音乐文件
		 * @param soundID
		 * @param loops
		 * @param soundTransform
		 * @return
		 */
		public function play(soundID : String, loops : int = 0, soundTransform : SoundTransform = null) : SoundReference
		{
			var sound : SoundReference = SReferenceManager.getInstance().getSoundReference(soundID);

			if (sound == null)
			{
				var soundClass : Class = getSoundClass(soundID);
				sound = SReferenceManager.getInstance().createSoundReference(soundID);
				sound.name = soundID;
			}
			else
			{
				sound.pause();
			}

			sound.play(0, loops, soundTransform);
			return sound;
		}

		/**
		 * 添加声音资源
		 * @param soundID
		 * @param resClass
		 *
		 */
		public function addSoundClass(soundID : String, resClass : Class) : void
		{
			soundClassDatas[soundID] = resClass;
		}

		public function getSoundClass(soundID : String) : Class
		{
			if (soundClassDatas[soundID] == null)
			{
				var resClass : Class = ApplicationDomain.currentDomain.getDefinition(soundID) as Class;

				if (!resClass)
					return null;
				addSoundClass(soundID, resClass);
			}
			return soundClassDatas[soundID];
		}

		/**
		 * 暂停播放一个音乐文件
		 * @param soundID
		 */
		public function pause(soundID : String) : void
		{
			var sound : SoundReference = SReferenceManager.getInstance().getSoundReference(soundID);
			sound && sound.pause();
		}

		/**
		 * 恢复一个音乐文件的播放，如果没有被暂停过，则直接播放
		 * @param soundID
		 */
		public function resume(soundID : String) : void
		{
			var sound : SoundReference = SReferenceManager.getInstance().getSoundReference(soundID);
			sound && sound.resume();
		}

		/**
		 * 暂停所有播放
		 */
		public function pauseAll() : void
		{
			var dic : Dictionary = SReferenceManager.getInstance().getReferencesByType(SReferenceManager.SOUND);
			for each (var sound : SoundReference in dic)
			{
				sound.pause();
			}
		}

		/**
		 * 恢复所有播放
		 */
		public function resumeAll() : void
		{
			var dic : Dictionary = SReferenceManager.getInstance().getReferencesByType(SReferenceManager.SOUND);
			for each (var sound : SoundReference in dic)
			{
				sound.resume();
			}
		}

		/**
		 * 关闭所有
		 */
		public function disposeAll() : void
		{
			var dic : Dictionary = SReferenceManager.getInstance().getReferencesByType(SReferenceManager.SOUND);
			for each (var sound : SoundReference in dic)
			{
				sound.close();
			}
			m_bgSound = null;
		}

		public function playBgSound(soundID : String) : void
		{
			if (m_bgSoundId == soundID)
				return;
			m_bgSoundId = soundID;
			if (m_bgSound)
				m_bgSound.pause();
			m_bgSound = play(soundID, 0, bgSoundTransform);

			if (m_bgSound && isOpenEffectSound)
				m_bgSound.pause();
		}

		/**
		 * 播放特效音乐
		 * @param soundID
		 * @param loops
		 *
		 */
		public function playEffectSound(soundID : String) : void
		{
			if (isOpenBgSound)
				return;
			play(soundID, 1, effectSoundTransform);
		}

		/**
		 * 暂停所有特效音乐
		 *
		 */
		public function pauseEffectSound() : void
		{
			pauseAll();
			isOpenBgSound = m_isOpenBgSound;
		}

		/**
		 * 恢复播放特效音乐
		 *
		 */
		public function resumeEffectSound() : void
		{
			resumeAll();
			isOpenBgSound = m_isOpenBgSound;
		}

		/**
		 * 设置背景音乐的音量
		 * @param vol
		 * @param panning
		 * @param leftToLeft
		 * @param leftToRight
		 * @param rightToLeft
		 * @param rightToRight
		 *
		 */
		public function setBgSoundTransform(vol : Number, panning : Number = 0, leftToLeft : Number = 1, leftToRight : Number = 1, rightToLeft : Number = 1, rightToRight : Number = 1) : void
		{
			bgSoundTransform.volume = vol;
			bgSoundTransform.pan = panning;
			bgSoundTransform.leftToLeft = leftToLeft;
			bgSoundTransform.leftToRight = leftToRight;
			bgSoundTransform.rightToLeft = rightToLeft;
			bgSoundTransform.rightToRight = rightToRight;

			if (m_bgSound)
				m_bgSound.setSoundTransform(bgSoundTransform);
		}

		/**
		 * 设置特效音乐的音量
		 * @param vol
		 * @param panning
		 * @param leftToLeft
		 * @param leftToRight
		 * @param rightToLeft
		 * @param rightToRight
		 *
		 */
		public function setEffectSoundTransform(vol : Number, panning : Number = 0, leftToLeft : Number = 1, leftToRight : Number = 1, rightToLeft : Number = 1, rightToRight : Number = 1) : void
		{
			effectSoundTransform.volume = vol;
			effectSoundTransform.pan = panning;
			effectSoundTransform.leftToLeft = leftToLeft;
			effectSoundTransform.leftToRight = leftToRight;
			effectSoundTransform.rightToLeft = rightToLeft;
			effectSoundTransform.rightToRight = rightToRight;
		}

		public function get isOpenEffectSound() : Boolean
		{
			return m_isOpenEffectSound;
		}

		public function set isOpenEffectSound(value : Boolean) : void
		{
			if (m_isOpenEffectSound == value)
				return;
			m_isOpenEffectSound = value;
			if (value)
				resumeEffectSound();
			else
				pauseEffectSound();
		}

		public function get isOpenBgSound() : Boolean
		{
			return m_isOpenBgSound;
		}

		public function set isOpenBgSound(value : Boolean) : void
		{
			if (m_isOpenBgSound == null)
				return;
			m_isOpenBgSound = value;
			if (!m_bgSound)
				return;
			if (value)
				m_bgSound.resume();
			else
				m_bgSound.pause();
		}


	}
}