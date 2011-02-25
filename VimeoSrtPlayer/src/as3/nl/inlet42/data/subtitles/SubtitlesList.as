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
		public function SubtitlesList(data:Array)
		{
			_data = data; 
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
			var lines:Array = [];
			for (var i:int=0,t:int=_data.length; i<t; i++) 
			{
				var line:SubtitleLine = _data[i];
				var resultObj:Object = {
					text: StringUtils.removeExtraWhitespace(line.text),
					start: line.start,
					end: line.end
				}
				lines.push( JSON.encode(resultObj) );  
			}
			return '{"lines":[' + lines.join(',') + ']}';	
		}
	}
}