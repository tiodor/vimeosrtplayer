package org.mindpirates.websubs
{
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.URLRequest;
	import flash.text.Font;
	
	import org.osflash.thunderbolt.Logger;
	
	import ru.etcs.utils.FontLoader;
	
	[Event(name="complete",type="flash.events.Event")]
	[Event(name="error",type="flash.events.ErrorEvent")]
	public class FontManager extends EventDispatcher
	{
		public const loader:FontLoader = new FontLoader();
		
		private var files:Array = []; 
		 
		private static const _instance:FontManager = new FontManager();
		
		public static function get instance():FontManager
		{
			return _instance;
		}
		
		public function FontManager()
		{
			if (_instance) {
				throw new Error('Singleton. Instantiation not allowed.');
			} 
		}
		
		public function loadFont(swf_url:String):void
		{
			if (files.indexOf(swf_url) != -1) {
				handleLoadComplete(null);
				return;
			}
			files.push(swf_url); 
			loader.addEventListener(Event.COMPLETE, handleLoadComplete);
			trace(this, 'loadFont('+swf_url+')');
			loader.load(new URLRequest(swf_url));
		}
		
		private function handleLoadComplete(e:Event):void
		{   
			trace('loaded fonts:')
			for each (var font:Font in loader.fonts) {
				trace('> '+font.fontName)
			} 
			dispatchEvent( new Event(Event.COMPLETE) );
		}
		 
	}
}