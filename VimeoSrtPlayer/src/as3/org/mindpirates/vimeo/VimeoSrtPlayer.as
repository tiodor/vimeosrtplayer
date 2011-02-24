package org.mindpirates.vimeo
{   
	import de.derhess.video.vimeo.VimeoEvent;
	import de.derhess.video.vimeo.VimeoPlayer;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import org.mindpirates.subtitles.SubtitlesConfig;
	import org.mindpirates.subtitles.SubtitlesLayer;
	import org.mindpirates.ui.Popup;
	import org.osflash.thunderbolt.Logger;
	  
	
	/** 
	 * @author Jovica Aleksic
	 */
	[SWF(width="450", height="225")]
	public class VimeoSrtPlayer extends Sprite
	{  
		public var player:VimeoPlayer;  
		public var subtitles:SubtitlesLayer;
		public static var instance:VimeoSrtPlayer;
		
		public function VimeoSrtPlayer()
		{ 
			addEventListener(Event.ADDED_TO_STAGE, handleAddedToStage, false, 0, true);
		}
		
		private function handleAddedToStage(e:Event):void
		{    
			player = new VimeoPlayer(loaderInfo, stage.stageWidth, stage.stageHeight); 
			player.addEventListener(VimeoEvent.PLAYER_LOADED, handlePlayerLoaded, false, 0, true); 
			addChild(player); 
		} 
		   
		private function handlePlayerLoaded(e:Event):void
		{      
			subtitles = new SubtitlesLayer(player);
			subtitles.init( new SubtitlesConfig(loaderInfo) );
			addChild(subtitles);
			
		}  
		
		
	}
}