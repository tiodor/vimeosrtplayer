package org.mindpirates.subtitles
{
	import de.derhess.video.vimeo.VimeoPlayer;
	
	import flash.external.ExternalInterface;
	
	import org.osflash.thunderbolt.Logger;

	public class JSInterface
	{
		
		private var player:VimeoSrtPlayer;
		
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
		} 
		private function loadSrt(file:String):void
		{
			player.subtitles.loadSrt(file);
		} 
		private function parseSrt(file:String=null,callback:*=null):String
		{
			return player.subtitles.parseSrt(file, callback);
		} 
		private function changeLine(oldLine:Object, newLine:Object):void
		{
		
		}
		public function fireEvent(event:JsEvent):void
		{
			try {
				//Logger.info('fireEvent('+event.type+')')
				ExternalInterface.call('onPlayerEvent', event.type, event);
			}
			catch (e:Error) {
				Logger.info('couldnt invoke onEvent');
			}
		}
		
		
		
	}
}