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
		private var mLoops : int = 0;
		private var mSound : Sound;
		private var mSoundChannel : SoundChannel;
		private var mSoundTransform : SoundTransform;
		public var name : String;

		public function SoundReference(param : Object)
		{
			if (param is Sound)
			{
				mSound = param as Sound;
			}
			else if (param is Class)
			{
				mSound = new param();
			}
		}

		public function setSoundTransform(value : SoundTransform) : void
		{
			if (mSoundChannel)
			{
				mSoundTransform = value;
				mSoundChannel.soundTransform = value;
			}
		}

		public function play(startTime : Number = 0, loops : int = 0, soundTransform : SoundTransform = null) : SoundChannel
		{
			if (mSoundChannel)
			{
				mSoundChannel.stop();
				mSoundChannel = null;
			}

			this.mLoops = loops;
			this.mSoundTransform = soundTransform;

			mSoundChannel = mSound.play(startTime, loops, soundTransform);
			if (mSoundChannel == null)
			{
				trace('无法播放该声音文件，原因：没有声卡或已经用完了可用的声道');
			}
			else
			{
				mSoundChannel.addEventListener(Event.SOUND_COMPLETE, onSoundComplete, false, 0, true);
			}
			return mSoundChannel;
		}

		/**
		 * 暂停播放
		 *
		 */
		public function pause() : void
		{
			mSoundChannel && mSoundChannel.stop();
		}

		/**
		 * 继续播放
		 *
		 */
		public function resume() : void
		{
			var startTime : int = mSoundChannel == null ? mSoundChannel.position : 0;
			play(startTime, mLoops, mSoundTransform);
		}

		/**
		 * 重新开始播放
		 *
		 */
		public function restart() : void
		{
			play(0, mLoops, mSoundTransform);
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
			if (mSound)
			{
				try
				{
					mSound.close();
				}
				catch (e : Error)
				{

				}
				mSound = null;
			}

			pause();
			mSoundChannel = null;
			mSoundTransform = null;
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