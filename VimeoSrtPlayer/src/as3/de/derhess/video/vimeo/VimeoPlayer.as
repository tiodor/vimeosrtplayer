package de.derhess.video.vimeo {
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.Sprite;
	import flash.display.StageDisplayState;
	import flash.events.Event;
	import flash.events.FullScreenEvent;
	import flash.events.IOErrorEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.media.Video;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.system.Security;
	import flash.utils.Timer;
	import flash.utils.getDefinitionByName;
	 
	 
	 
	
	/**
	 * released under MIT License (X11)
	 * http://www.opensource.org/licenses/mit-license.php
	 * 
	 * A wrapper class for Vimeo's video player (codenamed Moogaloop)
	 * that allows you to embed easily into any AS3 application.
     * 
	 * Documentation:
	 * 
	 * http://blog.derhess.de
	 * http://vimeo.com/api/docs/moogaloop
	 *
	 * Modified and extended by Florian Weil and Jovica Aleksic
	 * @author Florian Weil [derhess.de, Deutschland]
	 * @author Jovica Aleksic [mindpirates.org, Deutschland]
	 * @see http://blog.derhess.de
	 * @see http://mindpirates.org
	 */
 
	[Event(name="playerLoaded", type="de.derhess.video.vimeo.VimeoEvent")]
	[Event(name="duration", type="de.derhess.video.vimeo.VimeoEvent")]
	[Event(name="status", type="de.derhess.video.vimeo.VimeoEvent")]
	[Event(name="fullscreen", type="de.derhess.video.vimeo.VimeoEvent")]
	public class VimeoPlayer extends Sprite {
		
		//--------------------------------------------------------------------------
        //
        //  Class variables
        //
        //--------------------------------------------------------------------------
		public static const MOOGALOOP_URL:String = "http://api.vimeo.com/moogaloop_api.swf"; 
		
		public static var MAX_REPEAT_SAME_CURRENT_TIME:int = 3;
		
		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------
		
		
		
		/**
		 * A sprite that contains the video as well as the thumbnail images and functions to show them
		 */
		public var video_manager:Object;
		
		/**
		 * The actual video object instance within moogaloop
		 */
		public var video:Video;
		public var overlay:Sprite;
		
		
		private var container:Sprite = new Sprite(); // sprite that holds the player
		public var moogaloop:Object = false; // the player
		private var player_mask:Sprite = new Sprite(); // some sprites inside moogaloop go outside the bounds of the player. we use a mask to hide it
		
		public var ui:VimeoPlayerUI; // gives references to UI elements within moogaloop
		
		private var load_timer:Timer = new Timer(200);
		private var event_timer:Timer = new Timer(100);
		
		private var playerColor:String = "";
		private var volume:Number = 100;
		private var duration:Number = 0;
		private var isDurationChanged:Boolean = true;
		
		private var oldCurrentTime:Number = 0;
		private var completeCurrentTimeCounter:int = 0;
		private var playedOnce:Boolean = false;
		private var url:String;
		
		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------
		public var player_width:int = 400; // To Change the player size use the setSize(w,h) function
		public var player_height:int = 300; // To Change the player size use the setSize(w,h) function
		public var enableCompleteEvent:Boolean = true; // when set this to false, the wrapper class will stop dispatching Events - (Perfomance)
		public var enablePlayheadEvent:Boolean = true; // when set this to false, the wrapper class will stop dispatching Playing Status Events (Perfomance))
		
		//--------------------------------------------------------------------------
		//
		//  Additional getters and setters
		//
		//--------------------------------------------------------------------------
		/**
		 * return if the video is playing or not
		 * @return
		 */
		public function get isVideoPlaying():Boolean
		{
			return moogaloop.api_isPlaying();
		}
		//--------------------------------------------------------------------------
        //
        //  Initialization
        //
        //--------------------------------------------------------------------------
		private var clip_id:int; 
		private var loaderParams:Object;
		public function VimeoPlayer(info:LoaderInfo, w:int, h:int) {
			this.setDimensions(w, h);
			loaderParams = info.parameters;
			clip_id = loaderParams['vimeoId'];
			Security.allowDomain("*");
			Security.loadPolicyFile("http://vimeo.com/moogaloop/crossdomain.xml");
			url = MOOGALOOP_URL + "?clip_id="+clip_id + "&width=" + w + "&height=" + h + "&fullscreen=1";
 
			var loader:Loader = new Loader(); 
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, handleLoadingError, false, 0, true);
			loader.load(new URLRequest(url));
			
			addEventListener(VimeoEvent.STATUS, handleStatus, false, 0, true); 
			addEventListener(Event.ADDED_TO_STAGE, handleAddedToStage, false, 0, true);
			addEventListener(MouseEvent.CLICK, handleUIClick, true, 0, true);
			
		}
		private function handleLoadingError(e:Event):void
		{
			throw new Error('Failed loading '+url)
		}
		private function handleStatus(e:VimeoEvent):void
		{
			if (e.info == VimeoPlayingState.PLAYING && getCurrentVideoTime() > 0) {
				playedOnce = true;
			}
		}
		private function handleAddedToStage(e:Event):void
		{ 
			stage.addEventListener(FullScreenEvent.FULL_SCREEN, handleFullscreenChanged, false, 0, true)
		}
		
		
		/**
		 * Returns the current video playhead time in milli seconds
		 * @return
		 */
		public function getCurrentVideoTime():Number
		{
			return moogaloop.api_getCurrentTime();
		}
		
		/**
		 * returns duration of video in seconds
		 */
		public function getDuration():Number
		{	
			if (moogaloop.player_loaded )
			{
				var tDuration:Number = moogaloop.api_getDuration();
			
				if (isDurationChanged && (tDuration != duration))
				{
					isDurationChanged = false;
					duration = tDuration
					var e:VimeoEvent = new VimeoEvent(VimeoEvent.DURATION);
					e.duration = duration
					dispatchEvent(e);
					
				}
				return duration;
			}
				else
			{
				return 0;
			}
			
			
			
			
		}

		public function getPlayerColor():String
		{
			return playerColor;
		}
		
		/**
		 * set Volume for the video. Values between 0-100
		 */
		public function setVolume(value:Number):void
		{
			moogaloop.api_setVolume(value);
			volume = value;
		}
		
		public function getVolume():Number
		{
			return volume;
		}
		
		//--------------------------------------------------------------------------
        //
        //  FIXING SOME UI ACTIONS
        //
        //--------------------------------------------------------------------------
		private function handleUIClick(e:MouseEvent):void
		{    
			var stopEvent:Function = function(e:Event):void {
				e.stopImmediatePropagation();
				e.stopPropagation();
				e.preventDefault(); 
			};
			var clickOnThumbnail:Function = function(e:Event):Boolean {
				return 	e.target.parent && e.target.parent.toString() == '[object VimeoVideo]' && 
					e.target.parent.parent && e.target.parent.parent.toString() == '[object VideoManager]' && 
					e.target.parent.parent.parent && e.target.parent.parent.parent.toString() == '[object MoogaloopMain]';
			}
			var clickOnPlayButton:Function = function(e:Event):Boolean {
				return e.target.parent == ui.playButton;
			}	
			
			switch (e.target) {
				case ui.fullscreen_button:
					toggleFullscreen();
					stopEvent(e);
					break;
				default:
					if (clickOnThumbnail(e) || clickOnPlayButton(e)) {
						stopEvent(e);
						togglePlayback();
					} 
					break;
			}
		}
		
		public function togglePlayback():void
		{			
			if (isVideoPlaying) {
				pause();	
			}
			else {
				play();
			}
		}
		
		//--------------------------------------------------------------------------
		//
		//  FULLSCREEN HANDLING
		//
		//--------------------------------------------------------------------------
		
		private var _fullscreen:Boolean = false;
		
		public function set fullscreen(value:Boolean):void
		{
			if (value == _fullscreen) {
				return;
			} 
			stage.displayState = value ? StageDisplayState.FULL_SCREEN : StageDisplayState.NORMAL;  
			_fullscreen = value;
		}
		
		public function get fullscreen():Boolean
		{
			return _fullscreen;
		}
		
		public function toggleFullscreen():void
		{ 
			fullscreen = !fullscreen;
		} 
		private function handleFullscreenChanged(e:FullScreenEvent):void
		{   
			var wasPlaying:Boolean = isVideoPlaying;
			_fullscreen = e.fullScreen; // catching ESC-key exit
			try {
				setSize(stage.stageWidth, stage.stageHeight);
			}
			catch (e:Error) { 
				
				// when leaving fullscreen, moogaloop throws an error in api_setSize,
				// and afterwards the player controls are not visible.
				// we bring them back by calling play(), and if the player was not actually playing we call pause() immediatly.
				// problem: getCurrentVideoTime() changes, e.g. when toggling fullscreen before playback, getCurrentVideoTime() wion't be 0 anymore
				
				play(); 
				if (!wasPlaying) {
					pause(); 
				};
				
				// the fullscreen button gets stuck in its hover state, we fix it by manually setting the
				// upState as the new overState and revert the changes on its first rollover
				var overState:* = ui.fullscreen_button.overState;
				var fixState:Function = function(e:Event):void
				{ 
					ui.fullscreen_button.overState = overState;		
					ui.fullscreen_button.removeEventListener(MouseEvent.ROLL_OVER, fixState);
				}
				ui.fullscreen_button.overState = ui.fullscreen_button.upState;
				ui.fullscreen_button.addEventListener(MouseEvent.ROLL_OVER, fixState, false, 0, true);
				
				
				// When going to fullscreen before playback started, and leave fullscreen again before playback,
				// the thumbnail image is lost. Fix:   
				if (!playedOnce) {
					video_manager.showThumbnail();
				}
				
			} 
			
			var evt:VimeoEvent = new VimeoEvent( VimeoEvent.FULLSCREEN );
			evt.fullScreen = e.fullScreen;
			dispatchEvent(evt);
		}  
		 
		public function getInstanceByClass(container:*, className:String):DisplayObject
		{  
			if (!(container is DisplayObjectContainer)) {
				throw new Error('container must be a DisplayObjectContainer', container);
			}
			for (var i:int=0,num:int=container.numChildren; i<num; i++) {
				var o:DisplayObject = container.getChildAt(i); 
				if (o.toString() == '[object '+className+']') {
					return o;
				}
			}
			return null;
		}
		
		//--------------------------------------------------------------------------
        //
        //  API
        //
        //--------------------------------------------------------------------------
		public function stop():void
		{
			if (getCurrentVideoTime() > 0)
			{
				seekTo(0);
				pause();
				event_timer.stop();
				event_timer.reset();
				
				var e:VimeoEvent = new VimeoEvent(VimeoEvent.STATUS);
				e.duration = duration;
				e.info = VimeoPlayingState.STOP;
				dispatchEvent(e);
			}
		}
		
		public function play():void { 
			moogaloop.api_play();
			getDuration(); 
			if (enableCompleteEvent)
			{
				event_timer.start();				
			}
				else
			{
				var e:VimeoEvent = new VimeoEvent(VimeoEvent.STATUS);
				e.currentTime = getCurrentVideoTime();
				e.duration = 0;
				e.info = VimeoPlayingState.PLAYING;
				dispatchEvent(e);
			}
		}
		
		public function pause():void {
			moogaloop.api_pause();
			var e:VimeoEvent = new VimeoEvent(VimeoEvent.STATUS);
			e.currentTime = getCurrentVideoTime();
			e.duration = 0;
			e.info = VimeoPlayingState.PAUSE;
			dispatchEvent(e);
			event_timer.stop();
			event_timer.reset();
		}
		
		/**
		 * Seek to specific loaded time in video (in seconds)
		 */
		public function seekTo(time:int):void {
			moogaloop.api_seekTo(time);
			
			if (enablePlayheadEvent)
			{
				var vimeoPlayEvent:VimeoEvent = new VimeoEvent(VimeoEvent.STATUS);
				vimeoPlayEvent.currentTime = time;
				vimeoPlayEvent.duration = duration;
				vimeoPlayEvent.info = VimeoPlayingState.PLAYING;
				dispatchEvent(vimeoPlayEvent);
			}
		}
		
		public function unloadVideo():void
		{
			moogaloop.api_unload();
			var e:VimeoEvent = new VimeoEvent(VimeoEvent.STATUS);
			e.duration = 0;
			e.info = VimeoPlayingState.UNLOAD;
			dispatchEvent(e);
			event_timer.stop();
			event_timer.reset();
		}
		
		/**
		 * Load in a different video
		 */
		public function loadVideo(id:int):void {
			moogaloop.api_loadVideo(id);
			isDurationChanged = true;
			
			// reset duration property
			duration = 0;
			var e:VimeoEvent = new VimeoEvent(VimeoEvent.STATUS);
			e.duration = 0;
			e.info = VimeoPlayingState.NEW_VIDEO;
			dispatchEvent(e);
			event_timer.stop();
			event_timer.reset();
		}
		
		/**
		 * Change the size of the VideoPlayer
		 * @param	w width
		 * @param	h height
		 */
		public function setSize(w:int, h:int):void { 
			this.setDimensions(w, h);
			moogaloop.api_setSize(w, h);
			this.redrawMask();
		}
		
		
		/**
		 * Toggle loop for the video
		 * 
		 */
		public function toggleLoop():void
		{
			moogaloop.api_toggleLoop();
		}
		
		
		/////////////////////////////////////
		// Video & Vimeo Control Display
		/**
		 * This Function throws an error, because the embed player is not able to handle fullscreen mode, use instead setSize(w,h)
		 */
		/*public function toggleFullscreen():void
		{
			moogaloop.api_toggleFullscreen();
		}*/
		
		
		
		/**
		 * enable HD for the player, but it seems that it is not working?!
		 */
		public function hd_on():void
		{
			moogaloop.api_enableHDEmbed();
		}
		
		
		/**
		 * I think this function will be changed in the future ---> it seems that is not working?!
		 */
		public function hd_off():void
		{
			moogaloop.api_disableHDEmbed();
		}
		
		/**
		 * Change the primary color (i.e. 00ADEF) of the player vimeo gui controls
		 */
		public function changeColor(hex:String):void {
			moogaloop.api_changeColor(hex);
			playerColor = hex;
		}
		
		//////////////////////////////////////////
		// Screen Management
		public function showLikeScreen():void
		{
			moogaloop.onShowLikeScreen();
		}
		
		public function showEmbedScreen():void
		{
			moogaloop.onShowEmbedScreen();
		}
		
		public function showHDScreen():void
		{
			moogaloop.onShowHDScreen();
		}
		
		public function showShareScreen():void
		{
			moogaloop.onShowShareScreen();
		}
		
		public function showVimeoScreenControlls():void
		{
			moogaloop.onScreenShow( { } );
		}
		
		
		/**
         * Completely destroys the instance and frees all objects for the garbage
         * collector by setting their references to null.
         */
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
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMove);
			 
			removeEventListener(MouseEvent.CLICK, handleUIClick);
			stage.removeEventListener(FullScreenEvent.FULL_SCREEN, handleFullscreenChanged);
			
        }
		//--------------------------------------------------------------------------
        //
        //  Methods
        //
        //--------------------------------------------------------------------------
		private function setDimensions(w:int, h:int):void {
			player_width  = w;
			player_height = h;
		}
		
		private function onComplete(e:Event):void 
		{ 
			// Finished loading moogaloop
			container.addChild(e.target.loader.content);
			moogaloop = e.target.loader.content;
			
			
			// Create the mask for moogaloop
			addChild(player_mask);
			container.mask = player_mask;
			addChild(container);
			
			redrawMask();
			 
			load_timer.addEventListener(TimerEvent.TIMER, playerLoadedCheck);
			load_timer.start(); 
		}
		
		
		/**
		 * Wait for Moogaloop to finish setting up
		 */
		private function playerLoadedCheck(e:TimerEvent):void {
			if( moogaloop.player_loaded ) {
				// Moogaloop is finished configuring
				load_timer.stop();
				load_timer.removeEventListener(TimerEvent.TIMER, playerLoadedCheck);
				event_timer.addEventListener(TimerEvent.TIMER, handleEventTimer);

				// remove moogaloop's mouse listeners listener
				moogaloop.disableMouseMove(); 
				stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMove);
				
				
				
				// set references to moogaloop UI elements
				ui = new VimeoPlayerUI(this); 
				video_manager = getInstanceByClass(moogaloop, 'VideoManager');
				video = video_manager.getChildAt(0).getChildAt(0);
				overlay = video_manager.getChildAt(0).getChildAt(1);
				moogaloop.api_enableHDEmbed(); 
				var vimeoEvent:VimeoEvent = new VimeoEvent(VimeoEvent.PLAYER_LOADED);
				vimeoEvent.duration = 0;
				vimeoEvent.info = "";
				dispatchEvent(vimeoEvent);
			}
		}
		
		/**
		 * dispatch Event for the VideoStatus
		 * @param	e
		 */
		private function handleEventTimer(e:TimerEvent):void
		{ 
			var isPlaying:Boolean = true;
			var newCurrentTime:Number = getCurrentVideoTime();
			//Check if the currentTime Value already exists
			if (oldCurrentTime == newCurrentTime && oldCurrentTime != 0)
			{
				completeCurrentTimeCounter++;
			}
				else if(newCurrentTime == 0)
			{
				var vimeoEvent:VimeoEvent = new VimeoEvent(VimeoEvent.STATUS);
				vimeoEvent.currentTime = newCurrentTime;
				vimeoEvent.duration = getDuration();
				vimeoEvent.info = VimeoPlayingState.BUFFERING;
				dispatchEvent(vimeoEvent);
				isPlaying = false;
			}
			
			// It is almost impossible that the currentTime has the same value MAX_REPEAT_SAME_CURRENT_TIME times,
			// when it is playing. So I think the video playing is completed
			if (!isVideoPlaying && (completeCurrentTimeCounter >= MAX_REPEAT_SAME_CURRENT_TIME) )
			{
				var vimeoEventComplete:VimeoEvent = new VimeoEvent(VimeoEvent.STATUS);
				vimeoEventComplete.currentTime = getDuration();
				vimeoEventComplete.duration = getDuration();
				vimeoEventComplete.info = VimeoPlayingState.VIDEO_COMPLETE;
				dispatchEvent(vimeoEventComplete);
				event_timer.stop();
				event_timer.reset();
				isPlaying = false;
				oldCurrentTime = 0;
				completeCurrentTimeCounter = 0;
			}
				else
			{
				oldCurrentTime = newCurrentTime;
			}
			
			
			// Dispatch Video when Playing
			if (enablePlayheadEvent && isPlaying)
			{
				var vimeoPlayEvent:VimeoEvent = new VimeoEvent(VimeoEvent.STATUS);
				vimeoPlayEvent.currentTime = getCurrentVideoTime();
				vimeoPlayEvent.duration = getDuration();
				vimeoPlayEvent.info = VimeoPlayingState.PLAYING;
				dispatchEvent(vimeoPlayEvent);
			}
			
		}
		
		/**
		 * Fake the mouse move/out events for Moogaloop
		 */
		private function mouseMove(e:MouseEvent):void {  
			if( this.mouseX >= this.x && this.mouseX <= this.x + this.player_width &&
				this.mouseY >= this.y && this.mouseY <= this.y + this.player_height ) {
				moogaloop.mouseMove(e);
			}
			else {
				moogaloop.mouseOut();
			}
		}
		
		private function redrawMask():void {
			with( player_mask.graphics ) {
				beginFill(0x000000, 1);
				drawRect(container.x, container.y, player_width, player_height);
				endFill();
			}
		}
		
		
	}
}