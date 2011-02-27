package org.mindpirates.subtitles
{   
	import de.derhess.video.vimeo.VimeoEvent;
	import de.derhess.video.vimeo.VimeoPlayer;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	
	import org.mindpirates.subtitles.xml.ConfigXML;
	import org.osflash.thunderbolt.Logger;
	
	  
	
	/** 
	 * VimeoSrtPlayer
	 * Displays .srt subtitles with moogaloop.swf
	 * http://code.google.com/p/vimeosrtplayer/
	 * 
	 * @author Jovica Aleksic
	 */
	[SWF(width="450", height="225")]
	public class VimeoSrtPlayer extends Sprite
	{  
		public var config:ConfigXML;
		public var player:VimeoPlayer;  
		public var subtitles:SubtitlesLayer;
		public var js:JSInterface;
		public static var instance:VimeoSrtPlayer;
		public function VimeoSrtPlayer()
		{ 		
			addEventListener(Event.ADDED_TO_STAGE, handleAddedToStage, false, 0, true);
			config =  new ConfigXML(loaderInfo);
		}
		
		private function handleAddedToStage(e:Event):void
		{    
			if (ExternalInterface.available) {
				js = new JSInterface();
			}
			player = new VimeoPlayer(loaderInfo, stage.stageWidth, stage.stageHeight, js); 
			player.addEventListener(VimeoEvent.PLAYER_LOADED, handlePlayerLoaded, false, 0, true); 
			addChild(player); 
		} 
		   
		private function handlePlayerLoaded(e:Event):void
		{       
			subtitles = new SubtitlesLayer(player);
			subtitles.init( config );
			addChild(subtitles);
			js.initCallbacks(this);
		}  
		
		public function destroy():void
		{
			subtitles.destroy();
			player.destroy();
		}
		
	}
}