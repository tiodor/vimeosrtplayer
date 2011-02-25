package org.mindpirates.subtitles
{
	public class JsEvent
	{
		public static const MOOGALOOP_READY:String = "moogaloopReady";
		public static const MOOGALOOP_ERROR:String = "moogaloopError";
		public static const LOAD_SRT:String = "loadSrt";
		public static const SRT_ERROR:String = "srtError";
		public static const SRT_LOADED:String = "srtLoaded";
		public static const FULLSCREEN_CHANGED:String = "fullscreenChanged";
		public static const LOAD_LOCALIZATION:String = "loadLocalization";
		public static const LOCALIZATION_ERROR:String = "localizationError";
		public static const LOCALIZATION_LOADED:String = "localizationLoaded";
		public static const LANGUAGE_CHANGED:String = "languageChanged";
		public static const VOLUME_CHANGED:String = "volumeChanged";
		public static const PLAY:String = "play";
		public static const PAUSE:String = "pause";
		public static const SEEK:String = "seek";
		public static const SUBTITLE_TEXT:String = "subtitleText";
		
		
		public var type:String;
		public var moogaloopUrl:String;
		public var duration:Number;
		public var srtUrl:String; 
		public var fullscreen:Boolean;
		public var localizationUrl:String;
		public var lang:String;
		public var langName:String;
		public var volume:Number;
		public var position:Number;
		public var text:String;
		
		public function JsEvent(name:String)
		{
			type = name;
		}
	}
}