package nl.inlet42.data.subtitles { 
	
	/**
	 *	@author Jovica Aleksic
	 */

	public class SubtitleLine {
		private var _text : String;
		private var _start : Number;
		private var _duration : Number;
		private var _end : Number;
		
		public function SubtitleLine(inText : String = "",inStart : Number = 0,inDuration : Number = 0,inEnd : Number = 0) {
			text = inText;
			start = inStart;
			duration = inDuration;
			end = inEnd;
		}
		
		
		public function set text(value:String):void
		{
			_text = value;	
		}
		
		public function get text():String
		{
			return _text;
		}
		
		
		
		public function set start(value:Number):void
		{
			_start = roundToDigit(value,3);	
		}
		
		public function get start():Number
		{
			return _start;
		}
		 

		
		public function set duration(value:Number):void
		{
			_duration = roundToDigit(value,3);	
		}
		
		public function get duration():Number
		{
			return _duration;
		}
		
		
		
		public function set end(value:Number):void
		{
			_end = roundToDigit(value,3);	
		}
		
		public function get end():Number
		{
			return _end;
		}
		
		 
		private function roundToDigit(num:Number, nrOfDigits:Number):Number 
		{ 		 
			var factor:Number = Math.pow(10,nrOfDigits); 
			return Math.round(num*factor)/factor; 
		} 
	}
}