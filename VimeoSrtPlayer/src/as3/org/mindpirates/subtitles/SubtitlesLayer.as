package org.mindpirates.subtitles
{
	import com.chewtinfoil.utils.StringUtils; 
	
	import de.derhess.video.vimeo.VimeoEvent;
	import de.derhess.video.vimeo.VimeoPlayer;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Graphics;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	import flash.geom.Transform;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.text.AntiAliasType;
	import flash.text.Font;
	import flash.text.StyleSheet;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.utils.Timer;
	import flash.utils.getDefinitionByName;
	
	import nl.inlet42.data.subtitles.SubtitleLine;
	import nl.inlet42.data.subtitles.SubtitleParser;
	import nl.inlet42.data.subtitles.SubtitlesList;
	 
	/** 
	 * @author Jovica Aleksic
	 */
	  
	[Event(name="complete",type="flash.events.Event")]
	public class SubtitlesLayer extends Sprite
	{ 
		public var textField:SubtitleTextField;
		public var player:VimeoPlayer; 
		public var currentSubtitleLine:SubtitleLine;		 
		public var currentScale:Number = 1; 
		private var _config:SubtitlesConfig;		
		private var _text:String;
		private var originalSize:Object;
		private var list:SubtitlesList;
		private var timer:Timer;
		public function SubtitlesLayer(vimeoPlayer:VimeoPlayer)
		{  
			super();
			
			mouseEnabled = false; 
			mouseChildren = false;
				
			player = vimeoPlayer;  
			player.addEventListener(VimeoEvent.FULLSCREEN, handleFullscreenChange, false, 0, true);
			
			originalSize = {width:player.player_width,height:player.player_height};
			 
			 
		} 
		 
		public function init(config:SubtitlesConfig):void
		{ 
			_config = config;
			
			timer = new Timer(40);
			timer.addEventListener(TimerEvent.TIMER, handleTimer, false, 0, true);
			
			textField = new SubtitleTextField(config);
			textField.width = player.player_width; 
			player.video_manager.addChild(textField);
			
			loadSrt(config.url); 
			 
		}
		
		public function get config():SubtitlesConfig
		{
			return _config;
		}
		
		//-------------------------------------------------------------------------------------------
		//
		// EVENT HANDLING
		// 
		//-------------------------------------------------------------------------------------------
		
		 
		private function handleFullscreenChange(e:VimeoEvent):void
		{	 
			currentScale = player.player_width / originalSize.width; 
			textField.scale = currentScale;
		} 
		
		
		private function handleTimer(e:Event):void
		{       
			// update text
			if (player.isVideoPlaying) { 
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
			} 
			if (_text) {  		
				// update text position		
				updateTextPosition();
			}
				
			
		} 
		
		
		
		//-------------------------------------------------------------------------------------------
		//
		// TEXT HANDLING
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
		// LOADING THE SRT FILE
		// 
		//-------------------------------------------------------------------------------------------
		
		 
		
		public function loadSrt(file:String):void
		{
			var urlLoader:URLLoader = new URLLoader( new URLRequest( file ) );
			urlLoader.addEventListener(Event.COMPLETE, handleSrtLoaded, false, 0, true);
			urlLoader.addEventListener(IOErrorEvent.IO_ERROR, handleSrtError, false, 0, true);
			urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, handleSrtError, false, 0, true);
		} 
		private function handleSrtError(e:Event):void
		{
			throw new Error('Failed loading subtitles: ' + e);
		}
		private function handleSrtLoaded(e:Event):void
		{  
			var lines:Array = SubtitleParser.parseSRT( e.target.data.toString() );
			list = new SubtitlesList(lines);			
			timer.start(); 			
			dispatchEvent( new Event( Event.COMPLETE ) ); 
		}
	}
}