package org.mindpirates.video
{
    /** 
     * based on code by Florian Weil [derhess.de, Switzerland]
	 * @author Jovica Aleksic [mindpirates.org, Deutschland]
     */
     
	import flash.events.Event; 
	 
    public class VideoEvent extends Event
    { 
        public static const DURATION:String = "vimeoDurationChange";
		public static const STATUS:String = "vimeoStatus";
		public static const PLAYER_LOADED:String = "vimeoPlayerLoaded";
		public static const FULLSCREEN:String = "vimeoPlayerFullscreen";
		
		
		public var currentTime:Number;
		public var duration:Number;
		public var info:String;
		public var fullScreen:Boolean; 
		
        public function VideoEvent(type : String, bubbles : Boolean = false, cancelable : Boolean = false)
        {
            super(type, bubbles, cancelable);
			
			currentTime = 0;
			duration = 0;
			info = "";
        }
		 
        override public function clone():Event 
        {	
        	var event:VideoEvent = new VideoEvent(type);
        	event.info = this.info;
        	event.currentTime = this.currentTime;
        	event.duration = this.duration;
            return event;
        }
        
        override public function toString():String 
        {
            return "VimeoEvent{info:" + info + ", currentTime:" + currentTime.toString()+",duration:"+duration.toString()+"}";
        }
        
        
        
    }
}