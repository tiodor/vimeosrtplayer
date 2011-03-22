package org.mindpirates.video.vimeo
{ 
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.display.StageDisplayState;
	import flash.events.Event;
	import flash.events.FullScreenEvent;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.media.Video;
	import flash.net.URLRequest;
	import flash.system.Security;
	import flash.utils.Timer;
	
	import mx.events.Request;
	
	import org.mindpirates.video.VideoEvent;
	import org.mindpirates.video.VideoPlayState;
	import org.mindpirates.video.interfaces.IExternalPlayerWrapper;
	import org.mindpirates.video.interfaces.IVideoPlayer;
	import org.mindpirates.video.interfaces.IVideoPlayerUI;
	import org.mindpirates.websubs.JsEvent;
	import org.mindpirates.websubs.SubtitlesLayer;
	import org.mindpirates.websubs.VimeoAuth;
	import org.mindpirates.websubs.WebsubsJsInterface;
	import org.osflash.thunderbolt.Logger;
	
	[Event(name="playerLoaded", type="org.mindpirates.video.VideoEvent")]
	[Event(name="duration", type="org.mindpirates.video.VideoEvent")]
	[Event(name="status", type="org.mindpirates.video.VideoEvent")]
	[Event(name="fullscreen", type="org.mindpirates.video.VideoEvent")]
	public class MoogaloopWrapper extends Sprite implements IExternalPlayerWrapper, IVideoPlayer
	{
		public static const MOOGALOOP_URL:String = "http://api.vimeo.com/moogaloop_api.swf";
		public static const VIMEO_POLICY_URL:String = "http://vimeo.com/moogaloop/crossdomain.xml";
		
		public var container:Sprite = new Sprite();
		public var moogaloop:Object;		
		 
		
		internal var player_mask:Sprite = new Sprite(); 
		internal var load_timer:Timer = new Timer(200);
		internal var event_timer:Timer = new Timer(100); 		
		internal var loaderParams:Object; 
		internal var loader:Loader;
		 
		// private variables that hold values for public getters
		internal var _clip_id:int;
		internal var _fullscreenMode:Boolean=false;
		internal var _jsInterface:WebsubsJsInterface;
		internal var _playerWidth:Number;
		internal var _playerHeight:Number;		
		internal var _ui:IVideoPlayerUI;
		internal var _volume:Number;
		internal var _videoDuration:Number = 0; 
		internal var _videoManager:Object;	
		
		
		// more moogaloop specific (used for workarounds etc)	
		public var enableCompleteEvent:Boolean = true; // when set this to false, the wrapper class will stop dispatching Events - (Perfomance)
		public var enablePlayheadEvent:Boolean = true; // when set this to false, the wrapper class will stop dispatching Playing Status Events (Perfomance))
		public var enableMouseMove:Boolean = true;	
		private var __isVolumeDragging:Boolean;	
		private var __oldCurrentTime:Number = 0;
		private var __completeCurrentTimeCounter:int = 0;
		private var __playedOnce:Boolean = false;	
		private static var MAX_REPEAT_SAME_CURRENT_TIME:int = 3;
		 
		public function seekBy(value:Number):void
		{
			
		}
		public function get playerUrl():String
		{
			return MOOGALOOP_URL 
			+ '?fp_version=9'
				+ '&oauth_key=' + VimeoAuth.CONSUMER_KEY
				+ '&clip_id=' + (clip_id || '')
				+ '&width=' + _playerWidth 
				+ '&height=' + _playerHeight 
				+ '&fullscreen=1' 
				+ (loaderParams.queryParams ? '&'+loaderParams.queryParams : '');
		}
		
		public function MoogaloopWrapper(info:LoaderInfo, w:int, h:int, js:WebsubsJsInterface)
		{
			super();
						
			loaderParams = info.parameters;
			Security.allowDomain("*");
			Security.loadPolicyFile( VIMEO_POLICY_URL ); 
			 
			_clip_id = loaderParams['vimeo_id'] || loaderParams['vimeoId']; // vimeoId is deprecated. TODO: remove everywhere else.
			_playerWidth = w;
			_playerHeight = h;
			_jsInterface = js;
			
			
			addEventListener(Event.ADDED_TO_STAGE, handleAddedToStage, false, 0, true);
			addEventListener(MouseEvent.MOUSE_DOWN, handleMouseDown, true, 0, true);
			addEventListener(MouseEvent.MOUSE_UP, handleMouseUp, true, 0, true);  
			addEventListener(MouseEvent.CLICK, handleClick, true, 0, true);
			addEventListener(VideoEvent.STATUS, handleStatus, false, 0, true);
			
		}
		
		/**
		 * @private
		 * Registers a listener for fullscreen changes. I think this is needed to avoid bugs when the user leaves fullscreen using the ESC key.
		 * TODO: check.
		 */
		internal function handleAddedToStage(e:Event):void
		{ 
			stage.addEventListener(FullScreenEvent.FULL_SCREEN, handleFullscreenChanged, false, 0, true);
			loadPlayer();
		}
		 
		public function loadPlayer():void
		{  
			loader = new Loader(); 
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, handlePlayerLoadComplete);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, handlePlayerLoadError, false, 0, true);
			loader.load( new URLRequest(playerUrl) );  
		}
		
		
		public function handlePlayerLoadError(e:IOErrorEvent):void
		{
			if (jsInterface) {
				var event:JsEvent = new JsEvent(JsEvent.MOOGALOOP_ERROR);
				event.moogaloopUrl = playerUrl;
				jsInterface.fireEvent(event);
			}
			throw new Error('Failed loading vimeo player from "'+playerUrl+'"');
		}
		
		
		public function handlePlayerLoadComplete(e:Event):void
		{ 
			container.addChild(e.target.loader.content);
			moogaloop = e.target.loader.content as Sprite;
			 
			addChild(player_mask);
			container.mask = player_mask;
			addChild(container);
			
			redrawMask();
			
			load_timer.addEventListener(TimerEvent.TIMER, playerLoadedCheck);
			load_timer.start(); 
		}
		
		internal function createUI():void
		{
			_ui = new MoogaloopUI(moogaloop);		
		}
		internal function handleMoogaloopReady():void
		{ 
			
			moogaloop.api_enableHDEmbed(); 
			
			// override mouse move handling
			moogaloop.disableMouseMove(); 
			stage.addEventListener(MouseEvent.MOUSE_MOVE, handleMouseMove);
			
			// user interface
			
			createUI();
			
			if (jsInterface) {
				var event:JsEvent = new JsEvent(JsEvent.MOOGALOOP_READY);
				event.duration = videoDuration;
				event.moogaloopUrl = playerUrl;
				jsInterface.fireEvent(event);
			}
			
			var vimeoEvent:VideoEvent = new VideoEvent(VideoEvent.PLAYER_LOADED);
			vimeoEvent.duration = 0;
			vimeoEvent.info = "";
			dispatchEvent(vimeoEvent);
			
			if (loaderParams.preload) {
				play();
				pause();
				videoManager.showThumbnail();
				__playedOnce = false;
			}
			 
			
		}
		
		
		
		public function play():void
		{ 
			setSize(playerWidth, playerHeight);
			Logger.info('play()')
			moogaloop.api_play();
			if (enableCompleteEvent)
			{
				event_timer.start();				
			}
			else
			{
				var e:VideoEvent = new VideoEvent(VideoEvent.STATUS);
				e.currentTime = videoPosition;
				e.duration = 0;
				e.info = VideoPlayState.PLAYING;
				dispatchEvent(e); 
				
			}
			if (jsInterface) {
				var event:JsEvent = new JsEvent(JsEvent.PLAY);
				event.position = videoPosition;
				jsInterface.fireEvent(event);
			}
		}
		
		public function pause():void
		{
			moogaloop.api_pause();
			
			event_timer.stop();
			event_timer.reset();
			
			var e:VideoEvent = new VideoEvent(VideoEvent.STATUS);
			e.currentTime = videoPosition;
			e.duration = 0;
			e.info = VideoPlayState.PAUSE;
			dispatchEvent(e);
			
			
			if (jsInterface) {
				var event:JsEvent = new JsEvent(JsEvent.PAUSE);
				event.position = videoPosition;
				jsInterface.fireEvent(event);
			}
		}
		
		public function togglePlayback():void
		{
			if (isPlaying) {
				pause();
			}
			else {
				play();
			}
		}
		
		public function seekTo(value:Number):void
		{ 
			moogaloop.api_seekTo(value);
			
			if (enablePlayheadEvent)
			{
				var vimeoPlayEvent:VideoEvent = new VideoEvent(VideoEvent.STATUS);
				vimeoPlayEvent.currentTime = value;
				vimeoPlayEvent.duration = videoDuration;
				vimeoPlayEvent.info = VideoPlayState.PLAYING;
				dispatchEvent(vimeoPlayEvent);
				
				if (jsInterface) {
					var jsEvent:JsEvent = new JsEvent(JsEvent.SEEK);
					jsEvent.position = videoDuration;
					jsInterface.fireEvent(jsEvent);
				}
			}
		}
		 
		public function loadVideo(id:*):void {
			moogaloop.api_loadVideo(id); 
			
			_videoDuration = 0;
			
			event_timer.stop();
			event_timer.reset();
			
			var event:VideoEvent = new VideoEvent(VideoEvent.STATUS);
			event.duration = 0;
			event.info = VideoPlayState.NEW_VIDEO;
			dispatchEvent(event);
		}
		
		
		//-------------------------------------------------------------------------------
		//
		// READ-ONLY GETTERS
		//
		//-------------------------------------------------------------------------------
		
		public function get ui():IVideoPlayerUI
		{
			return _ui;
		}
		
		public function get video():Video
		{
			return videoManager.getChildAt(0).getChildAt(0);
		}
		
		public function get isPlaying():Boolean
		{
			return moogaloop.api_isPlaying();
		}
		
		public function get videoPosition():Number
		{
			return moogaloop.api_getCurrentTime();		
		}
		 
		public function get videoDuration():Number
		{ 
			return moogaloop.player_loaded  ? moogaloop.api_getDuration() : 0; 
		}
		  
		public function get jsInterface():WebsubsJsInterface
		{
			return _jsInterface;
		}
		
		public function get videoManager():Object
		{ 
			if (!_videoManager) {  
				for (var i:int=0,num:int=(moogaloop as DisplayObjectContainer).numChildren; i<num; i++) {
					var o:DisplayObject = moogaloop.getChildAt(i); 
					if (o.toString() == '[object VideoManager]') {
						_videoManager = moogaloop.getChildAt(i);
					}
				}
			}
			return _videoManager as Object;
		}
		
		
		
		
		//-------------------------------------------------------------------------------
		//
		// FULLSCREEN
		//
		//-------------------------------------------------------------------------------
		
		public function set fullscreenMode(value:Boolean):void
		{
			if (value == _fullscreenMode) {
				return;
			}  
			stage.displayState = value ? StageDisplayState.FULL_SCREEN : StageDisplayState.NORMAL;  
			_fullscreenMode = value;
		}
		
		public function get fullscreenMode():Boolean
		{
			return _fullscreenMode;
		}
		 
		public function toggleFullscreen():void
		{
			fullscreenMode = !fullscreenMode;
		}
		
		
		
		
		//-------------------------------------------------------------------------------
		//
		// SIZE
		//
		//-------------------------------------------------------------------------------
	 
		/**
		 * Changes the size of the VideoPlayer
		 * @param	w width
		 * @param	h height
		 */
		public function setSize(w:int, h:int):void {  
			this.setDimensions(w, h);  
			Logger.info('1. setSize('+w+', '+h+')')
				try {
			moogaloop.api_setSize(w, h);
				}
				catch (e:Error) {
					Logger.error(e.message,e)
				}
			Logger.info('2. setSize('+w+', '+h+')')
			this.redrawMask();
		}	
		
		/**
		 * @private
		 * Sets the values for the read-only playerWidth and playerHeight properties. 
		 * TODO: deprecate
		 * @param w width
		 * @param h height
		 */
		private function setDimensions(w:int, h:int):void {
			_playerWidth  = w;
			_playerHeight = h;
		} 
		
		public function get playerWidth():Number
		{
			return _playerWidth;
		}	 
		
		public function get playerHeight():Number
		{
			return _playerHeight;
		} 
		
		 
		
		public function set volume(value:Number):void
		{
			_volume = value;
			moogaloop.api_setVolume(value);  
			if (jsInterface) {
				var event:JsEvent = new JsEvent(JsEvent.VOLUME_CHANGED);
				event.volume = value;
				jsInterface.fireEvent(event);
			}
		}
		public function get volume():Number
		{
			return _volume;
		}
		 
		public function get clip_id():int
		{
			return _clip_id;
		}
		
		public function destroy():void
		{
			pause();
			
			if (player_mask && player_mask.stage)
			{	
				removeChild(player_mask);
				player_mask = null;
			}
			
			if (moogaloop && moogaloop.stage)
			{
				moogaloop = null;
			}
			
			if (container && container.stage)
			{
				removeChild(container);
				container = null;
			}
			
			load_timer = null;
			event_timer.removeEventListener(TimerEvent.TIMER, handleEventTimer);
			event_timer = null;
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, handleMouseMove); 
			stage.removeEventListener(FullScreenEvent.FULL_SCREEN, handleFullscreenChanged);			
		}
		
		//------------------------------------------------------------
		//
		// MOOGALOOP-SPECIFIC CODE
		//
		//------------------------------------------------------------
		
		/**
		 * Wait for Moogaloop to finish setting up
		 */
		private function playerLoadedCheck(e:TimerEvent):void {
			
			
			if( moogaloop.player_loaded ) {				
				load_timer.stop();
				load_timer.removeEventListener(TimerEvent.TIMER, playerLoadedCheck);
				event_timer.addEventListener(TimerEvent.TIMER, handleEventTimer);				
				handleMoogaloopReady();				
			}
		}
		
		
		private function stopEvent(e:Event):void {
			e.stopImmediatePropagation();
			e.stopPropagation();
			e.preventDefault(); 
		};
		
		
		
		/**
		 * @private
		 * TODO: Doc, where is __playedOnce needed?
		 */
		private function handleStatus(e:VideoEvent):void
		{
			if (!__playedOnce && e.info == VideoPlayState.PLAYING && videoPosition > 0) {
				__playedOnce = true;
			}
		}
		
		/**
		 * @private
		 * Prevents some default events that would lead to an error and applies workarounds instead. 
		 */
		private function handleMouseDown(e:MouseEvent):void
		{     
			if ( e.target == ui.volumeSlider || ui.volumeSlider.contains(e.target as DisplayObject) ) {
				
				/*
				* VOLUME SLIDER
				* changing the volume using moogaloop's volume bar causes an IO_Error ("NetworkError: 401 Unauthorized - http://vimeo.com/moogaloop/set_preference/")
				* workaround by stopping the MOUSE_DOWN event and handling volume changes via the api_setVolume function
				*/
				
				stopEvent(e);
				 
				volume = e.localX / ui.volumeSlider.width * 100;
				
				__isVolumeDragging = true;
				ui.volumeSlider.addEventListener(MouseEvent.MOUSE_MOVE, handleVolumeMouseMove, false, 0, true); 
				ui.playbar.addEventListener(MouseEvent.MOUSE_MOVE, handlePlaybarMouseMove, false, 0, true);
			}
		}
		
		private function handleMouseUp(e:MouseEvent):void
		{ 
			if (__isVolumeDragging) {
				ui.playbar.removeEventListener(MouseEvent.MOUSE_MOVE, handlePlaybarMouseMove);
				ui.volumeSlider.removeEventListener(MouseEvent.MOUSE_MOVE, handleVolumeMouseMove);
				ui.volumeSlider.removeEventListener(MouseEvent.MOUSE_UP, handleVolumeMouseMove);
			}
		}
		 
		/**
		 * Prevents some default events that would lead to an error and calls api functions instead.
		 * Fixes fullscreen button and thumbnail image issues.
		 */
		private function handleClick(e:MouseEvent):void
		{  	   
			if( e.target == ui.fullscreenButton || e.target.parent == ui.fullscreenButton) { 
				toggleFullscreen();
				stopEvent(e);
			}
			
			
			var clickOnThumbnail:Function = function(e:Event):Boolean {
				return 	e.target.parent && e.target.parent.toString() == '[object VimeoVideo]' && 
					e.target.parent.parent && e.target.parent.parent.toString() == '[object VideoManager]' && 
					e.target.parent.parent.parent && e.target.parent.parent.parent.toString() == '[object MoogaloopMain]';
			}
			var clickOnPlayButton:Function = function(e:Event):Boolean {
				return e.target == ui.playButton || e.target.parent == ui.playButton;
			}
			if (clickOnThumbnail(e) || clickOnPlayButton(e)) {
				stopEvent(e);
				togglePlayback();
			}
			
		}
		
		/**
		 * @private
		 * required for volume slider handling
		 * @see handleMouseDown
		 */
		private function handleVolumeMouseMove(e:MouseEvent):void
		{ 
			var r:Number = e.localX / ui.volumeSlider.width;
			
			volume = r*100;
		} 
		 
		/**
		 * @private
		 * required for volume slider handling
		 * @see handleMouseDown
		 */
		private function handlePlaybarMouseMove(e:MouseEvent):void
		{
			if (e.stageY > ui.volumeSlider.y && e.stageY < (ui.volumeSlider.y + ui.volumeSlider.height) ) {
				if (e.stageX < ui.volumeSlider.x) {
					volume = 0;
				}
				if (e.stageX > ui.volumeSlider.x + ui.volumeSlider.width) {
					volume = 100
				}
			} 
		} 
		
		private function handleFullscreenChanged(e:FullScreenEvent):void
		{   	 
			var wasPlaying:Boolean = isPlaying;
			_fullscreenMode = e.fullScreen; // catching ESC-key exit
			
			
			try {
				setSize(stage.stageWidth, stage.stageHeight); 
			}
			catch (e:Error) {  
				Logger.info('Error handling fullscreen change')
				// when Flash Player leaves the fullscreen mode, moogaloop throws an error in api_setSize,
				// and afterwards the player controls are not visible.
				// we bring them back by calling play(), and if the player was not actually playing we call pause() immediatly.
				// downside: videoPosition changes slightly
				 
				play();  
				if (!wasPlaying) {
					pause(); 
				};
				  
				
				// When going to fullscreen before playback started, and leave fullscreen again before playback,
				// the thumbnail image is lost. Fix:    
				if (!__playedOnce) {
					try { 
						videoManager.showThumbnail();
						moogaloop.api_unload();
					}
					catch (e:Error) {
						throw new Error('failed to call videoManager.showThumbnail()');
					}
				}
				
			} 
			
			var evt:VideoEvent = new VideoEvent( VideoEvent.FULLSCREEN );
			evt.fullScreen = e.fullScreen;
			dispatchEvent(evt);
			 
		}  
		
		
		/**
		 * @private
		 */
		private function redrawMask():void {
			with( player_mask.graphics ) {
				beginFill(0x000000, 1);
				drawRect(container.x, container.y, playerWidth, playerHeight);
				endFill();
			}
		}
		
		
		/**
		 * Fakes the mouse move/out events for Moogaloop
		 */
		private function handleMouseMove(e:MouseEvent):void { 
			if (!enableMouseMove) {
				return;
			}
			if( this.mouseX >= this.x && this.mouseX <= this.x + this.playerWidth &&
				this.mouseY >= this.y && this.mouseY <= this.y + this.playerHeight ) {
				moogaloop.mouseMove(e);
			}
			else {
				moogaloop.mouseOut();
			}
		}
		
		
		
		
		/**
		 * dispatch Event for the VideoStatus
		 * @param	e
		 */
		private function handleEventTimer(e:TimerEvent):void
		{  
			var isPlaying:Boolean = true;
			var newCurrentTime:Number = videoPosition;
			//Check if the currentTime Value already exists
			if (__oldCurrentTime == newCurrentTime && __oldCurrentTime != 0)
			{
				__completeCurrentTimeCounter++;
			}
			else if(newCurrentTime == 0)
			{
				var vimeoEvent:VideoEvent = new VideoEvent(VideoEvent.STATUS);
				vimeoEvent.currentTime = newCurrentTime;
				vimeoEvent.duration = videoDuration;
				vimeoEvent.info = VideoPlayState.BUFFERING;
				dispatchEvent(vimeoEvent);
				isPlaying = false;
			}
			
			// It is almost impossible that the currentTime has the same value MAX_REPEAT_SAME_CURRENT_TIME times,
			// when it is playing. So I think the video playing is completed
			if (!moogaloop.api_isPlaying() && (__completeCurrentTimeCounter >= MAX_REPEAT_SAME_CURRENT_TIME) )
			{
				var vimeoEventComplete:VideoEvent = new VideoEvent(VideoEvent.STATUS);
				vimeoEventComplete.currentTime = videoDuration;
				vimeoEventComplete.duration = videoDuration;
				vimeoEventComplete.info = VideoPlayState.VIDEO_COMPLETE;
				dispatchEvent(vimeoEventComplete);
				event_timer.stop();
				event_timer.reset();
				isPlaying = false;
				__oldCurrentTime = 0;
				__completeCurrentTimeCounter = 0;
			}
			else
			{
				__oldCurrentTime = newCurrentTime;
			}
			
			
			// Dispatch Video when Playing
			if (enablePlayheadEvent && isPlaying)
			{
				var vimeoPlayEvent:VideoEvent = new VideoEvent(VideoEvent.STATUS);
				vimeoPlayEvent.currentTime = videoPosition;
				vimeoPlayEvent.duration = videoDuration;
				vimeoPlayEvent.info = VideoPlayState.PLAYING;
				dispatchEvent(vimeoPlayEvent);
			}
			
		}
	}
}