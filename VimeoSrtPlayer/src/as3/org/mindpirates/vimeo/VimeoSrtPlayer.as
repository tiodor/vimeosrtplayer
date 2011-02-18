package org.mindpirates.vimeo
{   
	import de.derhess.video.vimeo.VimeoEvent;
	import de.derhess.video.vimeo.VimeoPlayer;
	import de.derhess.video.vimeo.VimeoPlayingState;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.StageDisplayState;
	import flash.events.Event;
	import flash.events.FullScreenEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.system.Security;
	import flash.utils.Timer;
	
	import nl.inlet42.data.subtitles.SubtitleLine;
	import nl.inlet42.data.subtitles.SubtitleParser;
	import nl.inlet42.data.subtitles.SubtitlesList;
	
	import org.mindpirates.subtitles.SubtitlesConfig;
	import org.mindpirates.subtitles.SubtitlesLayer; 
	
	
	/** 
	 * @author Jovica Aleksic
	 */
	[SWF(width="450", height="225")]
	public class VimeoSrtPlayer extends Sprite
	{  
		public var player:VimeoPlayer;  
		public var subtitles:SubtitlesLayer;
		
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
			var srtConfig:SubtitlesConfig = new SubtitlesConfig(loaderInfo);
			if (srtConfig.url) {
				subtitles = new SubtitlesLayer(player);
				subtitles.init(srtConfig);
				addChild(subtitles);
			}
		} 
		 
		
		
	}
}