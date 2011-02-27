package nl.inlet42.data.subtitles
{
	import com.adobe.serialization.json.JSON;
	import com.chewtinfoil.utils.StringUtils;
	
	import flash.system.System;
	
	import org.osflash.thunderbolt.Logger;
	 

	/** 
	 * @author Jovica Aleksic
	 */
	public class SubtitlesList
	{
		private var _data:Array;
		private var start_positions:Array;
		public var url:String;
		public function SubtitlesList(data:Array, src:String)
		{ 
			_data = data; 
			url = src;
		} 
		public function get list():Array
		{
			return _data;
		}
		public function getLineAtTime(time:Number):SubtitleLine
		{ 
			var result:SubtitleLine; 
			for (var i:int=0,t:int=_data.length; i<t; i++) 
			{
				var line:SubtitleLine = _data[i];
				if (line.start <= time && line.end >= time) {
					result = line;
				}
			}
			return result;
		}
		public function toJson():String
		{
			var result:Object = {
				src: url,
				lines: []
			} 
			for (var i:int=0,t:int=_data.length; i<t; i++) 
			{
				var line:SubtitleLine = _data[i];
				var resultObj:Object = {
					text: StringUtils.removeExtraWhitespace(line.text),
					start: line.start,
					end: line.end
				}
				result.lines.push( resultObj );  
			}
			
			return JSON.encode( result );	
		}
		
		public function replaceLine(oldLine:SubtitleLine, newline:SubtitleLine):void
		{
			
		}
	}
}