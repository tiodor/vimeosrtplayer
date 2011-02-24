package org.mindpirates.subtitles.xml
{ 
	 
	public class LocalizationXML extends XMLProxy
	{
		public function LocalizationXML(url:String=null)
		{
			super(url);
		}
		public function get languages():Array
		{ 
			var result:Array = []; 
			for each (var prop:XML in data.srt) 
			{ 
				result.push( String(prop.@lang) ); 
			}
			return result;
		}
		public function get files():Array
		{
			var result:Array = [];
			for each (var prop:XML in data.srt) 
			{ 
				result.push( prop.toString() ); 
			}
			return result;
		}
		public function getFileByLang(lang:String):String
		{
			return data.srt.(@lang==lang).toString();
		}
		
		public function get iconsPath():String
		{
			return data.@iconsPath;
		}
		
		public function get defaultLang():String
		{
			return data.@defaultLang;
		}
	}
}