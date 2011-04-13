package org.mindpirates.websubs
{ 
	
	import flash.external.ExternalInterface;
	import flash.text.TextFormat;
	
	import nl.inlet42.data.subtitles.SubtitleLine;
	
	import org.osflash.thunderbolt.Logger;

	public class WebsubsJsInterface
	{
		
		private var player:VimeoSrtPlayer;
		private var jsApiReady:Boolean = false;
		public function WebsubsJsInterface()
		{
		}
		public function initCallbacks(srtPlayer:VimeoSrtPlayer):void
		{
			player = srtPlayer;
			ExternalInterface.addCallback('loadSrt', loadSrt);
			ExternalInterface.addCallback('setSrtData', setSrtData);
			ExternalInterface.addCallback('parseSrt', parseSrt);
			ExternalInterface.addCallback('changeLine', changeLine);
			ExternalInterface.addCallback('play', player.player.play);
			ExternalInterface.addCallback('pause', player.player.pause);
			ExternalInterface.addCallback('togglePlayback', player.player.togglePlayback);
			ExternalInterface.addCallback('seekTo', player.player.seekTo);
			ExternalInterface.addCallback('seekBy', player.player.seekBy);
			ExternalInterface.addCallback('addListener', addExternalListener);
			
			ExternalInterface.addCallback('hideLanguageMenu', hideLanguageMenu);
			ExternalInterface.addCallback('showLanguageMenu', showLanguageMenu);
			ExternalInterface.addCallback('enableLanguageMenu', enableLanguageMenu);
			ExternalInterface.addCallback('disableLanguageMenu', disableLanguageMenu);
			ExternalInterface.addCallback('hasLanguageMenu', hasLanguageMenu);
			
			ExternalInterface.addCallback('getCurrentSrt', getCurrentSrt);
			
			ExternalInterface.addCallback('getCurrentLine', getCurrentLine);
			
			ExternalInterface.addCallback('setFontSize', setFontSize);
			ExternalInterface.addCallback('getFontSize', getFontSize);
			ExternalInterface.addCallback('setFontMargin', setFontMargin);
			ExternalInterface.addCallback('getFontMargin', getFontMargin);
			ExternalInterface.addCallback('isPlaying', isPlaying);
			 			
			
			ExternalInterface.addCallback('setWidth', setWidth);
			ExternalInterface.addCallback('getWidth', getWidth);
			ExternalInterface.addCallback('setHeight', setHeight);
			ExternalInterface.addCallback('getHeight', getHeight);
			ExternalInterface.addCallback('setSize', setSize);
			ExternalInterface.addCallback('getSize', getSize);
			
			initJsAPI();
		} 
		private function initJsAPI():void
		{ 
			var js_api:XML = 
				<script>
					<![CDATA[ 
						(function() {
							if ('onSubtitleApiReady' in window) {
								onSubtitleApiReady();
							};
						})()
					]]>
				</script>;
			ExternalInterface.call(js_api);
			jsApiReady = true; 
			ExternalInterface.addCallback('ready', function(e:*=null):Boolean{return true;});
		}
		public function addExternalListener(type:String, handler:*):void
		{
			Logger.info('type: '+type+', handler: '+handler);
		}
		private function setSrtData(value:String):void
		{
			
		}
		private function loadSrt(file:String):void
		{
			Logger.info('loadSrt('+file+')')
			player.subtitles.loadSrt(file);
		} 
		private function parseSrt(file:String=null,callback:*=null):String
		{
			return player.subtitles.parseSrt(file, callback);
		} 
		private function changeLine(oldLine:Object, newLine:Object):void
		{ 
			//Logger.info('changeLine', oldLine, newLine);
			player.subtitles.changeLine(SubtitleLine.create(oldLine), SubtitleLine.create(newLine));
		}
		public function fireEvent(event:JsEvent):void
		{
			if (!jsApiReady) {
				return;
			}
			try {
				//Logger.info('fireEvent('+event.type+')')
				ExternalInterface.call('onPlayerEvent', event.type, event); 
				ExternalInterface.call('onSrtPlayerEvent', player.params.swfId, event.type, event);
			}
			catch (e:Error) {
				Logger.info('couldnt invoke onEvent');
			}
		}
		
		public function hideLanguageMenu():void
		{
			if (hasLanguageMenu()) {
				player.subtitles.combo.visible = false;
			}
			else {
				player.subtitles.hideCombo = true;
			}
		}
		public function showLanguageMenu():void
		{ 
			if (hasLanguageMenu()) {
				player.subtitles.combo.visible = true;
			}
		}
		public function enableLanguageMenu():void
		{ 
			if (hasLanguageMenu()) {
				player.subtitles.enableCombo();
			}
		}
		public function disableLanguageMenu():void
		{ 
			if (hasLanguageMenu()) {
				player.subtitles.disableCombo();
			} 
		}
		private function hasLanguageMenu():Boolean
		{
			return player.subtitles.combo != null;
		}
		private function getCurrentSrt():String
		{
			return player.subtitles.currentSrtUrl;
		}
		private function setFontSize(value:Number):void
		{
			player.subtitles.textField.fontSize = value;
		}
		private function getFontSize():Number
		{
			return player.subtitles.textField.fontSize;
		}
		private function isPlaying():Boolean
		{
			return player.player.isPlaying;
		}
		private function getFontMargin():Number
		{
			return player.subtitles.config.margin;
		}
		private function setFontMargin(value:Number):void
		{
			player.subtitles.config.setMargin( value );
		}  
		private function getCurrentLine():Object
		{
			var line:SubtitleLine = player.subtitles.subtitleLine;
			var pos:int = player.subtitles.list.getLineIndex(line);
			var result:Object = line.toObject()
			result.index = pos;
			return result ;
		}
		private function setWidth(value:Number):void
		{
			player.player.setSize(value, player.player.playerHeight);
		}
		private function getWidth():Number
		{
			return player.player.playerWidth;
		}
		private function setHeight(value:Number):void
		{
			player.player.setSize(player.player.playerWidth, value);
		}
		private function getHeight():Number
		{
			return player.player.playerHeight;
		}
		private function setSize(w:Number, h:Number):void
		{
			//Logger.info('--> set size: ', w, h);
			player.player.setSize(Number(w), Number(h));
		}
		private function getSize():Array
		{
			return [player.player.playerWidth, player.player.playerHeight];
		}
		
	}
}