package org.mindpirates.subtitles
{
	import de.derhess.video.vimeo.VimeoPlayer;
	
	import flash.external.ExternalInterface;
	
	import nl.inlet42.data.subtitles.SubtitleLine;
	
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
			ExternalInterface.addCallback('seekTo', player.player.seekTo);
			ExternalInterface.addCallback('addListener', addExternalListener);
			Logger.info('srtPlayer.config.swfId: '+srtPlayer.config.swfId);
			ExternalInterface.call('onSubtitleApiReady', srtPlayer.config.swfId);
		} 
		public function addExternalListener(type:String, handler:*):void
		{
			Logger.info('type: '+type+', handler: '+handler);
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
			player.subtitles.changeLine(SubtitleLine.create(oldLine), SubtitleLine.create(newLine));
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