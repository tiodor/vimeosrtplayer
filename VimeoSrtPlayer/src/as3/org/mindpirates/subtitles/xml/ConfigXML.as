package org.mindpirates.subtitles.xml
{  
	import flash.display.LoaderInfo;

	/** 
	 * @author Jovica Aleksic
	 */
	public class ConfigXML
	{
		private var _data:Object;
		public function ConfigXML(info:LoaderInfo)
		{ 
			_data = info.parameters;
		}
		public function get srt():String
		{
			return _data.srt;
		}
		public function get swfId():String
		{
			return _data.swfId;
		}
		public function get fontSize():Number
		{ 
			if (!_data.srtFontSize) {
				return 10;
			}
			return Number(_data.srtFontSize);
		}
		public function get margin():Number
		{
			if (!_data.srtMargin) {
				return 10;
			}
			return Number(_data.srtMargin);
		}
		public function get localization():String
		{
			if (!_data.localization) {
				return null;
			}
			return String(_data.localization);
		}
	}
}