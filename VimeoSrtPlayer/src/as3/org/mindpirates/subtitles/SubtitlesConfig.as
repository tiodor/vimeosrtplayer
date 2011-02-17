package org.mindpirates.subtitles
{  
	/** 
	 * @author Jovica Aleksic
	 */
	public class SubtitlesConfig
	{
		private var _data:Object;
		public function SubtitlesConfig(parameters:Object)
		{ 
			_data = parameters;
		}
		public function get url():String
		{
			return _data.srtUrl;
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
	}
}