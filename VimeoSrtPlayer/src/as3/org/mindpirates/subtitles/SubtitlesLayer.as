package org.mindpirates.subtitles
{ 
	import com.chewtinfoil.utils.StringUtils;
	
	import de.derhess.video.vimeo.VimeoEvent;
	import de.derhess.video.vimeo.VimeoPlayer;
	
	import fl.controls.ComboBox;
	import fl.data.DataProvider;
	
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.text.AntiAliasType;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.utils.Timer;
	
	import nl.inlet42.data.subtitles.SubtitleLine;
	import nl.inlet42.data.subtitles.SubtitleParser;
	import nl.inlet42.data.subtitles.SubtitlesList;
	
	import org.mindpirates.subtitles.xml.ConfigXML;
	import org.mindpirates.subtitles.xml.LocalizationXML;
	import org.mindpirates.subtitles.xml.XMLProxy;
	import org.mindpirates.utils.FontLoader;
	import org.mindpirates.utils.ISO_639_2B;
	import org.osflash.thunderbolt.Logger;
	 
	/** 
	 * @author Jovica Aleksic
	 */
	  
	
	[Event(name="complete",type="flash.events.Event")]
	public class SubtitlesLayer extends Sprite
	{ 
		public var combo:ComboBox;
		public var textField:SubtitleTextField;
		public var player:VimeoPlayer; 
		public var currentSubtitleLine:SubtitleLine;		 
		public var currentScale:Number = 1;  
		public var localization:LocalizationXML;
		private var _config:ConfigXML;		
		private var _text:String;
		private var originalSize:Object;
		private var list:SubtitlesList;
		private var timer:Timer;
		
		  
		public function SubtitlesLayer(vimeoPlayer:VimeoPlayer)
		{  
			super();
			   
			player = vimeoPlayer;  
			player.addEventListener(VimeoEvent.FULLSCREEN, handleFullscreenChange, false, 0, true); 
			
			originalSize = {width:player.player_width, height:player.player_height}; 
			 
		} 
		public function init(config:ConfigXML):void
		{ 
			_config = config;
			
			timer = new Timer(40);
			timer.addEventListener(TimerEvent.TIMER, handleTimer, false, 0, true);
			
			textField = new SubtitleTextField(config);
			textField.width = player.player_width; 
			player.video_manager.addChild(textField);
			
			if (config.srt) {
				loadSrt(config.srt); 
			}
			
			 
			initLocalization(); 
		}
		
		public function get config():ConfigXML
		{
			return _config;
		}
		 
		
		
		//-------------------------------------------------------------------------------------------
		//
		// GENERAL EVENT HANDLING
		// 
		//-------------------------------------------------------------------------------------------
		
		private function handleFullscreenChange(e:VimeoEvent):void
		{	 
			currentScale = player.player_width / originalSize.width; 
			textField.scale = currentScale;
			updateComboPosition(); 
			
			if (player.js) {
				var event:JsEvent = new JsEvent(JsEvent.FULLSCREEN_CHANGED);
				event.fullscreen = player.fullscreen;
				player.js.fireEvent(event);
			}
		} 
		
		
		private function handleTimer(e:Event):void
		{       
			// update text
			var line:SubtitleLine = list.getLineAtTime( player.getCurrentVideoTime() )  
			if (line) { 
				if (line != currentSubtitleLine) {
					currentSubtitleLine = line;
					text = line.text;
				}
			}
			else if (currentSubtitleLine) { 
				currentSubtitleLine = null; 
				text = ""; 
			}
			
			if (_text) {  		
				// update text position		
				updateTextPosition();
			} 
			
		} 
		 
		
		//-------------------------------------------------------------------------------------------
		//
		// SUBTITLE TEXT HANDLING
		// 
		//-------------------------------------------------------------------------------------------
		 
		public function set text(value:String):void
		{ 
			_text = value; 
			
			if (value) {
				value = '<span class="subtitle">' + 
					value.replace('\r\n','<br>')
						.replace('\r','<br>')
						.replace('\n','<br>')
						.replace('<b>','<strong>')
						.replace('</b>', '</strong>') 
					+ '</span>'
			} 
			textField.htmlText = StringUtils.removeExtraWhitespace(value); 
			updateTextPosition();
			
			
			if (player.js) {
				var event:JsEvent = new JsEvent(JsEvent.SUBTITLE_TEXT);
				event.text = _text;
				player.js.fireEvent(event);
			}
		} 
		
		public function get text():String
		{
			return _text;
		}
		 
		private function updateTextPosition():void
		{  
			var margin:Number = config.margin * currentScale + (player.ui.playbar.alpha ? player.ui.playButton.height : 0)
			textField.y = player.player_height - textField.textHeight*currentScale - margin; 
			
		}
		
		
		//-------------------------------------------------------------------------------------------
		//
		// LOCALIZATION (Multiple languages)
		// 
		//-------------------------------------------------------------------------------------------
 
		public function setLanguage(lang:String):void
		{
			var file:String = localization.getFileByLang(lang);
			loadSrt(file);
			for (var i:int=0,t:int=combo.dataProvider.length; i<t; i++) {
				var item:Object = combo.dataProvider.getItemAt(i);
				if (item.lang == lang) {
					combo.selectedIndex = i;
				}
			}
		}
		
		public var currentLanguage:Object;
		
		private function initLocalization():void
		{	
			if (config.localization) { 
				localization = new LocalizationXML();
				localization.addEventListener(XMLProxy.COMPLETE, handleLocalizationXmlComplete, false, 0, true);
				localization.addEventListener(XMLProxy.ERROR, handleLocalizationXmlError, false, 0, true); 
				localization.loadXML(config.localization);
				
				if (player.js) {
					var event:JsEvent = new JsEvent(JsEvent.LOAD_LOCALIZATION);
					event.localizationUrl = config.localization;
					player.js.fireEvent(event);
				}
			}	
		}
		
		private function handleLocalizationXmlComplete(e:Event):void
		{   
			createCombo();
			updateComboPosition(); 
			if (localization.defaultLang) {
				setLanguage(localization.defaultLang);
			}
			
			localization.removeEventListener(XMLProxy.COMPLETE, handleLocalizationXmlComplete);
			localization.removeEventListener(XMLProxy.ERROR, handleLocalizationXmlError); 
			
			if (player.js) {
				var event:JsEvent = new JsEvent(JsEvent.LOCALIZATION_LOADED);
				event.localizationUrl = config.localization;
				player.js.fireEvent(event);
			}
		}
		private function handleLocalizationXmlError(e:Event):void
		{
			throw new Error('Localization url '+config.localization+' not loaded!');
			localization.removeEventListener(XMLProxy.COMPLETE, handleLocalizationXmlComplete);
			localization.removeEventListener(XMLProxy.ERROR, handleLocalizationXmlError); 
			
			if (player.js) {
				var event:JsEvent = new JsEvent(JsEvent.LOCALIZATION_ERROR);
				event.localizationUrl = config.localization;
				player.js.fireEvent(event);
			}
		} 
		private function createCombo():void
		{
			combo = new ComboBox();  
			combo.addEventListener(Event.CHANGE, handleComboChange, false, 0, true); 
			combo.width = player.ui.playButton.width;
			combo.height = 20; 
			combo.setStyle('textPadding',2); 
			
			var format:TextFormat = new TextFormat()
			format.color = 0xFFFFFF;
			format.bold = true;
			format.font = new _UNI_05_53().fontName; 
			format.size = 8;
			
			combo.dropdown.setRendererStyle("embedFonts",true);
			combo.dropdown.setRendererStyle("textFormat",format);
			combo.dropdown.setRendererStyle("antiAliasType",AntiAliasType.NORMAL);
			
			combo.textField.setStyle("embedFonts",true); 
			combo.textField.setStyle("textFormat",format);
			combo.textField.setStyle("antiAliasType",AntiAliasType.NORMAL);
			combo.textField.textField.autoSize = TextFieldAutoSize.LEFT;
			
			var dp:Array = [{label:'no subtitle',lang:null}];
			for each (var lang:String in ISO_639_2B._codes) {  
				if (localization.languages.indexOf( lang ) != -1) {
					var name:String = ISO_639_2B.getNameByCode(lang); 
					var item:Object = {
						'name': name,
						'lang': lang,			
						'label': name		
					}
					dp.push(item); 
				}
			}
			combo.dataProvider = new DataProvider(dp);
			player.ui.playbar.addChild(combo);
			
		}
		private function handleComboChange(e:Event):void
		{  
			 
			var lang:String = combo.selectedItem.lang;
			var langName:String = ISO_639_2B.getNameByCode(lang);
			var srt:String = localization.getFileByLang(lang);
			var font:String = localization.getFontByLang(lang);
			
			if (player.js) {
				var event:JsEvent = new JsEvent(JsEvent.LANGUAGE_CHANGED);
				event.lang = lang;
				event.langName = langName;
				player.js.fireEvent(event);
			}
			 
			if (srt) {
				loadSrt(srt);				
			}
			
			if (font) {
				loadFont(font);
			}
			
		} 
		private function updateComboPosition():void
		{
			if (combo) { 
				combo.x = player.ui.playButton.x;
				combo.y = player.player_height - combo.height - player.ui.playButton.height - 20;
			}
		}
		
		//-------------------------------------------------------------------------------------------
		//
		// LOADING A FONT SWF
		// 
		//-------------------------------------------------------------------------------------------
		
		public function loadFont(url:String):void
		{/*
			var loader:FontLoader = new FontLoader();
			addChild(loader)
			loader.loadFont( url );
			*/
		}
			
		
		
		//-------------------------------------------------------------------------------------------
		//
		// LOADING THE SRT FILE
		// 
		//-------------------------------------------------------------------------------------------
		
		 
		public var currentSrtUrl:String;
		public function loadSrt(file:String):void
		{ 
			if (!file) {
				timer.stop();
				text = "";
				list = null;
				return;
			}
			var urlLoader:URLLoader = new URLLoader( new URLRequest( file ) );
			urlLoader.addEventListener(Event.COMPLETE, handleSrtLoaded, false, 0, true);
			urlLoader.addEventListener(IOErrorEvent.IO_ERROR, handleSrtError, false, 0, true);
			urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, handleSrtError, false, 0, true);
			currentSrtUrl = file;
			
			if (player.js) {
				var event:JsEvent = new JsEvent(JsEvent.LOAD_SRT);
				event.srtUrl = currentSrtUrl;
				player.js.fireEvent(event);
			}
		} 
		private function handleSrtError(e:Event):void
		{ 
			if (player.js) {
				var event:JsEvent = new JsEvent(JsEvent.SRT_ERROR);
				player.js.fireEvent(event);
			}
			throw new Error('Failed loading subtitles: ' + e);
		}
		private function handleSrtLoaded(e:Event):void
		{ 
			var lines:Array = SubtitleParser.parseSRT( e.target.data.toString() );
			list = new SubtitlesList(lines);			
			timer.start(); 			
			dispatchEvent( new Event( Event.COMPLETE ) ); 
			
			if (player.js) {
				var event:JsEvent = new JsEvent(JsEvent.SRT_LOADED);
				event.srtUrl = currentSrtUrl;
				player.js.fireEvent(event);
			}
		}
		
		
		
		
		public function changeLine(oldLine:SubtitleLine, newLine:SubtitleLine):void
		{
			
		}
		
		public function parseSrt(file:String=null, jsHandler:String=null):String
		{
			var result:String;
			if (!file) {
				result = list.toJson();
			}
			else { 
				var loaded:Function = function(e:Event):void {
					var lines:Array = SubtitleParser.parseSRT( e.target.data.toString() );  
					if (jsHandler && ExternalInterface.available) {
						var _list:SubtitlesList = new SubtitlesList(lines); 
						var _result:String = _list.toJson(); 
						ExternalInterface.call(jsHandler, _result);
					}
				}
				var error:Function = function(e:Event):void {
					throw new Error('could not load file '+file);
				} 
				var urlLoader:URLLoader = new URLLoader( new URLRequest( file ) );
				urlLoader.addEventListener(Event.COMPLETE, loaded, false, 0, true);
				urlLoader.addEventListener(IOErrorEvent.IO_ERROR, error, false, 0, true);
				urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, error, false, 0, true); 
			}
			return result;
		}
		
		public function destroy():void
		{ 
			if (combo) {
				combo.removeEventListener(Event.CHANGE, handleComboChange); 
			}
			player.removeEventListener(VimeoEvent.FULLSCREEN, handleFullscreenChange); 
			timer.removeEventListener(TimerEvent.TIMER, handleTimer);
			timer.stop();
		}
	}
}