package hy.game.sound
{
	import flash.events.Event;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;

	import hy.game.core.SReference;

	/**
	 * 声音处理
	 * @author yangyang
	 *
	 */
	public class SoundReference extends SReference
	{
		private var loops : int = 0;
		private var sound : Sound;
		private var soundChannel : SoundChannel;
		private var soundTransform : SoundTransform;
		public var name : String;

		public function SoundReference(param : Object)
		{
			if (param is Sound)
			{
				sound = param as Sound;
			}
			else if (param is Class)
			{
				sound = new param();
			}
		}

		public function setSoundTransform(value : SoundTransform) : void
		{
			if (soundChannel)
			{
				soundTransform = value;
				soundChannel.soundTransform = value;
			}
		}

		public function play(startTime : Number = 0, loops : int = 0, soundTransform : SoundTransform = null) : SoundChannel
		{
			if (soundChannel)
			{
				soundChannel.stop();
				soundChannel = null;
			}

			this.loops = loops;
			this.soundTransform = soundTransform;

			soundChannel = sound.play(startTime, loops, soundTransform);
			if (soundChannel == null)
			{
				trace('无法播放该声音文件，原因：没有声卡或已经用完了可用的声道');
			}
			else
			{
				soundChannel.addEventListener(Event.SOUND_COMPLETE, onSoundComplete, false, 0, true);
			}
			return soundChannel;
		}

		/**
		 * 暂停播放
		 *
		 */
		public function pause() : void
		{
			soundChannel && soundChannel.stop();
		}

		/**
		 * 继续播放
		 *
		 */
		public function resume() : void
		{
			var startTime : int = soundChannel == null ? soundChannel.position : 0;
			play(startTime, loops, soundTransform);
		}

		/**
		 * 重新开始播放
		 *
		 */
		public function restart() : void
		{
			play(0, loops, soundTransform);
		}

		public function close() : void
		{
			pause();
			release();
		}

		/**
		 * 释放对象
		 */
		override protected function destroy() : void
		{
			super.destroy();
			if (sound)
			{
				try
				{
					sound.close();
				}
				catch (e : Error)
				{

				}
				sound = null;
			}

			pause();
			soundChannel = null;
			soundTransform = null;
		}

		private function onSoundComplete(evt : Event) : void
		{
			var soundChannel : SoundChannel = evt.currentTarget as SoundChannel;
			soundChannel.removeEventListener(Event.SOUND_COMPLETE, onSoundComplete);
			//播放完成后自动释放
			release();
		}
	}
}