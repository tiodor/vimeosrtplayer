package org.mindpirates.utils
{
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.net.URLRequest;
	import flash.text.*;
	
	import org.osflash.thunderbolt.Logger;
	
	public class FontLoader extends Sprite {
		
		public function FontLoader() {
			graphics.beginFill(0xff0000,0)
				graphics.drawRect(0,0,100,100);
				graphics.endFill();
			//loadFont("_Arial.swf");
		}
		
		public function loadFont(url:String):void {
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, fontLoaded);
			loader.load(new URLRequest(url+'?time='+new Date().getTime()));
		}
		
		private function fontLoaded(event:Event):void {
			var FontLibrary:Class = event.target.applicationDomain.getDefinition("_DejaVu_Cyrillic") as Class;
			Logger.info('FontLibrary: '+FontLibrary)
			Font.registerFont(FontLibrary);
			Logger.info('FontLibrary: '+(FontLibrary as Font))
			drawText();
		}
		
		public function drawText():void {
			var tf:TextField = new TextField();
			tf.width = 200;
			tf.height = 100;
			tf.defaultTextFormat = new TextFormat("DejaVu Sans", 16, 0);
			tf.embedFonts = true;
			tf.antiAliasType = AntiAliasType.ADVANCED;  
			tf.autoSize = TextFieldAutoSize.LEFT;
			tf.border = true;
			tf.background = true;
			tf.text = "Scott was here\nАБВГДЕЖЅЗИІКЛМНОПҀРСТѸФХѠЦЧШЩЪꙐЬѢꙖѤЮѦѪѨѬѮѰѲѴ\nblah scott...:;*&^% "; 
			
			var embeddedFonts:Array = Font.enumerateFonts(false);
			embeddedFonts.sortOn("fontName", Array.CASEINSENSITIVE);
			Logger.info("\n\n----- Enumerate Fonts -----");
			for(var i:int = 0; i<embeddedFonts.length; i++) {
				Logger.info(embeddedFonts[i].fontName);
			}
			Logger.info("---------------------------\n\n");
			Logger.info(new _DejaVu().fontName)
			addChild(tf);
		}
	}
}