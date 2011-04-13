package org.mindpirates.websubs
{  
	import flash.display.LoaderInfo;
	
	import org.osflash.thunderbolt.Logger;

	/** 
	 * @author Jovica Aleksic
	 */
	public class Params
	{
		private var _data:Object;
		public function Params(info:LoaderInfo)
		{ 
			_data = info.parameters;
		}
		public function get srt():String
		{
			return _data.srt;
		}
		public function get srtData():String
		{
			return _data.srtData;
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
		public function setMargin(value:Number):void
		{
			_data.srtMargin = value;
		}
		public function get localization():String
		{
			if (!_data.localization) {
				return null;
			}
			return String(_data.localization);
		}
		public function get lang():String
		{
			if (!_data.lang) {
				return null;
			}
			return String(_data.lang);
		}
		public function get queryParamString():String
		{
			if (!_data.queryParams) {
				return null;
			}
			return String(_data.queryParams);
		} 
		public function get dynpos():Boolean
		{
			if (!_data.dynpos) {
				return true;
			}
			return _data.dynpos == 'true' || _data.dynpos == '1';
		} 
		/**
		 * Whether or not to display the language menu
		 */
		public function get menu():Boolean
		{ 
			if (!_data.menu) {
				return true;
			}
			if ( _data.menu == 'false' || _data.menu == '0' ) {
				return false;
			}
			return true;
		} 
		public function get playerClass():String
		{
			if (!_data.playerClass) {
				return null;
			}
			return String(_data.playerClass);
		} 
		public function get embedUrl():String
		{
			if (!_data.embedUrl) {
				return null;
			}
			return String(_data.embedUrl);
		}
		public function get shareUrl():String
		{
			if (!_data.shareUrl) {
				return null;
			}
			return String(_data.shareUrl);
		}
		
	}
}