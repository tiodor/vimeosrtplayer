package org.mindpirates.video.interfaces
{
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.media.Video;
	
	import org.mindpirates.websubs.SubtitlesLayer;
	import org.mindpirates.websubs.WebsubsJsInterface;

	public interface IVideoPlayer extends IEventDispatcher
	{ 
		function play():void;
		
		function pause():void;
		
		function seekTo(value:Number):void;
		function seekBy(value:Number):void;
		 
		function loadVideo(clip_id:*):void;
		
		function togglePlayback():void;
		function toggleFullscreen():void;
		
		function get video():Video;
		
		function get isPlaying():Boolean;
		
		function get ui():IVideoPlayerUI;
		
		function get videoPosition():Number;
		function get videoDuration():Number;
		  
		function get fullscreenMode():Boolean;
		function set fullscreenMode(value:Boolean):void;
						
		function setSize(w:Number,h:Number):void;
		function get playerWidth():Number; 
		
		function get playerHeight():Number; 
		
		function get jsInterface():WebsubsJsInterface;  
		
		function set volume(value:Number):void;
		function get volume():Number;
		
		function destroy():void;
		
	}
}