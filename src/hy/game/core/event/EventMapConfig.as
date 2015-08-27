//------------------------------------------------------------------------------
//  Copyright (c) 2009-2013 the original author or authors. All Rights Reserved. 
// 
//  NOTICE: You are permitted to use, modify, and distribute this file 
//  in accordance with the terms of the license agreement accompanying it. 
//------------------------------------------------------------------------------

package hy.game.core.event
{
	/**
	 * @private
	 */
	public class EventMapConfig
	{

		/*============================================================================*/
		/* Public Properties                                                          */
		/*============================================================================*/

		private var mDispatcher : SEventDispatcher;

		/**
		 * @private
		 */
		public function get dispatcher() : SEventDispatcher
		{
			return mDispatcher;
		}

		private var mEventString : String;

		/**
		 * @private
		 */
		public function get eventString() : String
		{
			return mEventString;
		}

		private var mListener : Function;

		/**
		 * @private
		 */
		public function get listener() : Function
		{
			return mListener;
		}

		private var mEventClass : Class;

		/**
		 * @private
		 */
		public function get eventClass() : Class
		{
			return mEventClass;
		}

		private var mCallback : Function;

		/**
		 * @private
		 */
		public function get callback() : Function
		{
			return mCallback;
		}

		/*============================================================================*/
		/* Constructor                                                                */
		/*============================================================================*/

		/**
		 * @private
		 */
		public function EventMapConfig(dispatcher : SEventDispatcher, eventString : String, listener : Function, eventClass : Class, callback : Function)
		{
			mDispatcher = dispatcher;
			mEventString = eventString;
			mListener = listener;
			mEventClass = eventClass;
			mCallback = callback;
		}

		public function equalTo(dispatcher : SEventDispatcher, eventString : String, listener : Function, eventClass : Class) : Boolean
		{
			return mEventString == eventString && mEventClass == eventClass && mDispatcher == dispatcher && mListener == listener;
		}
	}
}
