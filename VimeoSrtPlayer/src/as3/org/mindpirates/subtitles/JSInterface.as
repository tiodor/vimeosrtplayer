package org.mindpirates.subtitles
{
	import de.derhess.video.vimeo.VimeoPlayer;
	
	import flash.external.ExternalInterface;
	import flash.text.TextFormat;
	
	import nl.inlet42.data.subtitles.SubtitleLine;
	
	import org.osflash.thunderbolt.Logger;

	public class JSInterface
	{
		
		private var player:VimeoSrtPlayer;
		private var jsApiReady:Boolean = false;
		public function JSInterface()
		{
		}
		public function initCallbacks(srtPlayer:VimeoSrtPlayer):void
		{
			player = srtPlayer;
			ExternalInterface.addCallback('loadSrt', loadSrt);
			ExternalInterface.addCallback('parseSrt', parseSrt);
			ExternalInterface.addCallback('changeLine', changeLine);
			ExternalInterface.addCallback('play', player.player.play);
			ExternalInterface.addCallback('pause', player.player.pause);
			ExternalInterface.addCallback('seekTo', player.player.seekTo);
			ExternalInterface.addCallback('addListener', addExternalListener);
			
			ExternalInterface.addCallback('hideLanguageMenu', hideLanguageMenu);
			ExternalInterface.addCallback('showLanguageMenu', showLanguageMenu);
			ExternalInterface.addCallback('enableLanguageMenu', enableLanguageMenu);
			ExternalInterface.addCallback('disableLanguageMenu', disableLanguageMenu);
			ExternalInterface.addCallback('hasLanguageMenu', hasLanguageMenu);
			
			ExternalInterface.addCallback('getCurrentSrt', getCurrentSrt);
			
			initJsAPI();
		} 
		private function initJsAPI():void
		{ 
			var js_api:XML = 
				<script>
					<![CDATA[ 
						(function() {
							if ('srtApiReady' in window) {
								srtApiReady();
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
				ExternalInterface.call('onSrtPlayerEvent', player.config.swfId, event.type, event);
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
		
	}
}