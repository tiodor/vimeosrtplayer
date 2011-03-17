package de.derhess.video.vimeo {
	
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
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.media.Video;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.system.Security;
	import flash.system.SecurityDomain;
	import flash.ui.Keyboard;
	import flash.utils.Timer;
	import flash.utils.getDefinitionByName;
	
	import org.mindpirates.video.VideoEvent;
	import org.mindpirates.video.interfaces.IVideoPlayer;
	import org.mindpirates.video.interfaces.IVideoPlayerUI;
	import org.mindpirates.video.interfaces.IVimeoPlayer;
	import org.mindpirates.websrt.xml.ConfigXML;
	import org.mindpirates.websubs.JsEvent;
	import org.mindpirates.websubs.VimeoAuth;
	import org.mindpirates.websubs.VimeoSrtPlayer;
	import org.mindpirates.websubs.WebsubsJsInterface; 
	 
	 
	 
	
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
	public class VimeoPlayer extends Sprite implements IVimeoPlayer {
		
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
		
		private var _js:WebsubsJsInterface;
		public function get jsInterface():WebsubsJsInterface
		{
			return _js;
		}
		
		/**
		 * A sprite that contains the video as well as the thumbnail images and functions to show them
		 */
		private var _video_manager:Object;
		public function get videoManager():Object
		{
			return _video_manager;
		}
		/**
		 * The actual video object instance within moogaloop
		 */
		private var _video:Video;
		public function get video():Video
		{
			return _video;
		}
		public var loader:Loader;
		public var overlay:Sprite;
		
		 
		//public var embedSettings:XMLList;
		
		private var container:Sprite = new Sprite(); // sprite that holds the player
		public var moogaloop:Object = false; // the player
		private var player_mask:Sprite = new Sprite(); // some sprites inside moogaloop go outside the bounds of the player. we use a mask to hide it
		
		private var _ui:IVideoPlayerUI; // gives references to UI elements within moogaloop
		public function get ui():IVideoPlayerUI
		{
			return _ui;
		}
		private var load_timer:Timer = new Timer(200);
		private var event_timer:Timer = new Timer(100);
		
		private var playerColor:String = "";
		private var _volume:Number = 100;
		public function get volume():Number
		{
			return _volume;
		}
	 
		private var _duration:Number = 0;
		private var isDurationChanged:Boolean = true;
		
		private var oldCurrentTime:Number = 0;
		private var completeCurrentTimeCounter:int = 0;
		private var playedOnce:Boolean = false;
		private var url:String;
		private var isVolumeDragging:Boolean = false;
		public var keyboardSeekSeconds:Number = 2;
		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------
		private var _player_width:int = 400; // To Change the player size use the setSize(w,h) function
		private var _player_height:int = 300; // To Change the player size use the setSize(w,h) function
		public var enableCompleteEvent:Boolean = true; // when set this to false, the wrapper class will stop dispatching Events - (Perfomance)
		public var enablePlayheadEvent:Boolean = true; // when set this to false, the wrapper class will stop dispatching Playing Status Events (Perfomance))
		public function get playerWidth():Number
		{
			return _player_width;
		}
		public function get playerHeight():Number
		{
			return _player_height;
		}
		//--------------------------------------------------------------------------
		//
		//  Additional getters and setters
		//
		//--------------------------------------------------------------------------
		/**
		 * return if the video is playing or not
		 * @return
		 */
		public function get isPlaying():Boolean
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
		
		public function VimeoPlayer(info:LoaderInfo, w:int, h:int, jsInterface:WebsubsJsInterface=null) {
			this.setDimensions(w, h);  
			_js = jsInterface;
			loaderParams = info.parameters;
			clip_id = loaderParams['vimeoId'];
			Security.allowDomain("*");
			Security.loadPolicyFile("http://vimeo.com/moogaloop/crossdomain.xml"); 
			url = MOOGALOOP_URL + "?fp_version=9&oauth_key="+VimeoAuth.CONSUMER_KEY+"&clip_id="+clip_id + "&width=" + w + "&height=" + h + "&fullscreen=1" + (loaderParams.queryParams ? '&'+loaderParams.queryParams : '');
			
			loader = new Loader(); 
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, handleLoadingError, false, 0, true);
			loader.load(new URLRequest(url));
			
			addEventListener(VimeoEvent.STATUS, handleStatus, false, 0, true); 
			addEventListener(Event.ADDED_TO_STAGE, handleAddedToStage, false, 0, true);
			addEventListener(MouseEvent.CLICK, handleUIClick, true, 0, true);
			addEventListener(MouseEvent.MOUSE_DOWN, handleUIMouseDown, true, 0, true);
			addEventListener(MouseEvent.MOUSE_UP, handleUIMouseUp, true, 0, true);
			
			
		}
		private function handleLoadingError(e:Event):void
		{ 
			if (jsInterface) {
				var event:JsEvent = new JsEvent(JsEvent.MOOGALOOP_ERROR);
				event.moogaloopUrl = url;
				jsInterface.fireEvent(event);
			}
			throw new Error('Failed loading '+url)
		}
		private function handleStatus(e:VimeoEvent):void
		{
			if (e.info == VimeoPlayingState.PLAYING && videoPosition > 0) {
				playedOnce = true; 
			}
		}
		private function handleAddedToStage(e:Event):void
		{ 
			stage.addEventListener(FullScreenEvent.FULL_SCREEN, handleFullscreenChanged, false, 0, true);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, handleKeyDown, false, 0, true);
		}
		
		private var lastSeekOccuredTime:Number; /* real time when seekTo was called for the last time */
		private var lastSeekValue:Number; /* time value passed to seekTo last time it was called */ 
		public function seekBy(value:Number):void
		{ 
			var newTime:Number = videoPosition + value;
			
			if (lastSeekOccuredTime && new Date().getTime() < lastSeekOccuredTime + value*1000) {
				newTime = lastSeekValue + value;
			}
			
			seekTo( newTime );	
			
			lastSeekValue = newTime;
			lastSeekOccuredTime = new Date().getTime();
		}
		private function handleKeyDown(e:KeyboardEvent):void
		{ 
			var key:uint = e.keyCode; 
			switch (key) {
				case Keyboard.LEFT :					
					seekBy( -keyboardSeekSeconds * (e.shiftKey ? 5 : 1) );
					break;
				case Keyboard.RIGHT :
					seekBy( keyboardSeekSeconds * (e.shiftKey ? 5 : 1) );			 
					break;
				case Keyboard.UP :
					volume += 1;
					break;
				case Keyboard.DOWN :
					volume -= 1;
					break;
			}
			
		}
		
		/**
		 * Returns the current video playhead time in milli seconds
		 * @return
		 */
		public function get videoPosition():Number
		{
			return moogaloop.api_getCurrentTime();
		}
		
		/**
		 * returns duration of video in seconds
		 */
		public function get videoDuration():Number
		{	 
			//Logger.info('--> get videoDuration')
			if (moogaloop.player_loaded )
			{
				//Logger.info('--> player loaded')
				var tDuration:Number = moogaloop.api_getDuration();
				
				//Logger.info('--> tDuration '+tDuration)
				if (isDurationChanged && (tDuration != _duration))
				{
					//Logger.info('--> duration has changed')
					isDurationChanged = false;
					_duration = tDuration
					var e:VimeoEvent = new VimeoEvent(VimeoEvent.DURATION);
					e.duration = _duration
					dispatchEvent(e);
					//Logger.info('--> duration dispatched')
					
				} 
			} 
			
			//Logger.info('--> videoDuration: '+_duration)
			return _duration
			
		}

		public function getPlayerColor():String
		{
			return playerColor;
		}
		
		/**
		 * set Volume for the video. Values between 0-100
		 */
		public function set volume(value:Number):void
		{
			if (value < 0) value = 0;
			if (value > 100) value = 100;
			moogaloop.api_setVolume(value); 
			_volume = value;
			if (jsInterface) {
				var event:JsEvent = new JsEvent(JsEvent.VOLUME_CHANGED);
				event.volume = value;
				jsInterface.fireEvent(event);
			}
		}
		
		public function getVolume():Number
		{
			return volume;
		}
		
		//--------------------------------------------------------------------------
        //
        //  FIXING SOME UI STUFF
        //
        //--------------------------------------------------------------------------
		
		/**
		 * Fires a javascript event when seeking
		 */ 
		private function handleOnSeek(time:Number):void
		{
			if (jsInterface) {
				var event:JsEvent = new JsEvent(JsEvent.SEEK);
				event.position = time * videoDuration;
				jsInterface.fireEvent(event);
			}
		}
		/**
		 * Catches the JS callback of moogaloop and loops it back into our player to dispatch an event in our custom way
		 */
		private function enableSeekEvents():void
		{
			var js_code:XML = 
				<script>
					<![CDATA[
						function(swf_id) {
							window.onVimeoSeek = function(time){
								try { document.getElementById(swf_id).onApiSeek(time); }
								catch (err) {}
							};
						}
					]]>
				</script>; 
			
			ExternalInterface.call(js_code, loaderParams.swfId)
			ExternalInterface.addCallback('onApiSeek', handleOnSeek);
			moogaloop.api_addEventListener('onSeek', 'onVimeoSeek'); 
		}
		
		 
		private function stopEvent(e:Event):void {
			e.stopImmediatePropagation();
			e.stopPropagation();
			e.preventDefault(); 
		};
		
		
		private function handleUIMouseDown(e:MouseEvent):void
		{
			// changing the volume using moogaloop's volume bar causes an IO_Error ("NetworkError: 401 Unauthorized - http://vimeo.com/moogaloop/set_preference/")
			// workaround by stopping the MOUSE_DOWN event and handling volume changes via the api_setVolume function
			if (ui.volumeSlider.contains(e.target as DisplayObject)) {
				stopEvent(e);
				var r:Number = e.localX / ui.volumeSlider.width; 
				volume = r*100;
				isVolumeDragging = true;
				ui.volumeSlider.addEventListener(MouseEvent.MOUSE_MOVE, handleVolumeMouseMove, false, 0, true); 
				ui.playbar.addEventListener(MouseEvent.MOUSE_MOVE, handlePlaybarMouseMove, false, 0, true);
			}	
		}
		private function handleVolumeMouseMove(e:MouseEvent):void
		{ 
			var r:Number = e.localX / ui.volumeSlider.width;
			volume = r*100;
		} 
		private function handlePlaybarMouseMove(e:MouseEvent):void
		{
			if (e.stageY > ui.volumeSlider.y && e.stageY < (ui.volumeSlider.y + ui.volumeSlider.height) ) {
				if (e.stageX < ui.volumeSlider.x) {
					volume = 0;
				}
				if (e.stageX > ui.volumeSlider.x + ui.volumeSlider.width) {
					volume = 100;
				}
			} 
		}
		private function handleUIMouseUp(e:MouseEvent):void
		{
			if (isVolumeDragging) {
				ui.playbar.removeEventListener(MouseEvent.MOUSE_MOVE, handlePlaybarMouseMove);
				ui.volumeSlider.removeEventListener(MouseEvent.MOUSE_MOVE, handleVolumeMouseMove);
				ui.volumeSlider.removeEventListener(MouseEvent.MOUSE_UP, handleVolumeMouseMove);
			}
		}
		public function clickOnFullscreenButton(e:Event):Boolean {
			return e.target.parent.toString() == '[object FullscreenButton]';
		}
		
		/**
		 * Prevents some default events that would lead to an error and calls api functions instead.
		 * Fixes fullscreen button and thumbnail image issues.
		 */
		private function handleUIClick(e:MouseEvent):void
		{    
			var clickOnThumbnail:Function = function(e:Event):Boolean {
				return 	e.target.parent && e.target.parent.toString() == '[object VimeoVideo]' && 
					e.target.parent.parent && e.target.parent.parent.toString() == '[object VideoManager]' && 
					e.target.parent.parent.parent && e.target.parent.parent.parent.toString() == '[object MoogaloopMain]';
			}
			var clickOnPlayButton:Function = function(e:Event):Boolean {
				return e.target.parent == ui.playButton;
			}	 
		 
			//Logger.info('target: '+e.target.parent)
			switch (e.target) {
				case ui.fullscreenButton:
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
		
		private function handleSeek(e:Event):void
		{
			//Logger.info('seek!: '+e)
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
		
		//--------------------------------------------------------------------------
		//
		//  FULLSCREEN HANDLING
		//
		//--------------------------------------------------------------------------
		
		private var _fullscreen:Boolean = false;
		
		public function set fullscreenMode(value:Boolean):void
		{
			if (value == _fullscreen) {
				return;
			} 
			//Logger.info('fullscreen', value);
			stage.displayState = value ? StageDisplayState.FULL_SCREEN : StageDisplayState.NORMAL;  
			_fullscreen = value;
		}
		
		public function get fullscreenMode():Boolean
		{
			return _fullscreen;
		}
		
		public function toggleFullscreen():void
		{ 
			fullscreenMode = !fullscreenMode;
		} 
		private function handleFullscreenChanged(e:FullScreenEvent):void
		{   
			//Logger.info('--> handleFullscreenChanged()')
			var wasPlaying:Boolean = isPlaying;
			_fullscreen = e.fullScreen; // catching ESC-key exit
			try {
				setSize(stage.stageWidth, stage.stageHeight);
			}
			catch (e:Error) { 
				
				// when leaving fullscreen, moogaloop throws an error in api_setSize,
				// and afterwards the player controls are not visible.
				// we bring them back by calling play(), and if the player was not actually playing we call pause() immediatly.
				// problem: videoPosition changes, e.g. when toggling fullscreen before playback, videoPosition wion't be 0 anymore
			
				play(); 
				//Logger.info('---> wasPlaying: '+wasPlaying)
				if (!wasPlaying) {
					//Logger.info('---> PAUSE IT')
					pause(); 
				};
				var fsButton:SimpleButton = ui.fullscreenButton as SimpleButton;
				// the fullscreen button gets stuck in its hover state, we fix it by manually setting the
				// upState as the new overState and revert the changes on its first rollover
				var overState:* = fsButton.overState;
				var fixState:Function = function(e:Event):void
				{ 
					fsButton.overState = overState;		
					fsButton.removeEventListener(MouseEvent.ROLL_OVER, fixState);
				}
				fsButton.overState = fsButton.upState;
				fsButton.addEventListener(MouseEvent.ROLL_OVER, fixState, false, 0, true);
				
				
				// When going to fullscreen before playback started, and leave fullscreen again before playback,
				// the thumbnail image is lost. Fix:   
				if (!playedOnce) {
					videoManager.showThumbnail();
					moogaloop.api_unload();
				}
				
			} 
			
			var evt:VideoEvent = new VideoEvent( VideoEvent.FULLSCREEN );
			evt.fullScreen = e.fullScreen;
			dispatchEvent(evt);
			//Logger.info('--> dispatch event')
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
			if (videoPosition > 0)
			{
				seekTo(0);
				pause();
				event_timer.stop();
				event_timer.reset();
				
				var e:VimeoEvent = new VimeoEvent(VimeoEvent.STATUS);
				e.duration = videoDuration;
				e.info = VimeoPlayingState.STOP;
				dispatchEvent(e);
			}
		}
		
		public function play():void { 
			moogaloop.api_play();
			if (enableCompleteEvent)
			{
				event_timer.start();				
			}
				else
			{
				var e:VimeoEvent = new VimeoEvent(VimeoEvent.STATUS);
				e.currentTime = videoPosition;
				e.duration = 0;
				e.info = VimeoPlayingState.PLAYING;
				dispatchEvent(e); 
				
			}
			if (jsInterface) {
				var event:JsEvent = new JsEvent(JsEvent.PLAY);
				event.position = videoPosition;
				jsInterface.fireEvent(event);
			}
		}
		
		public function pause():void {
			//Logger.info('pause()')
			moogaloop.api_pause();
			var e:VimeoEvent = new VimeoEvent(VimeoEvent.STATUS);
			e.currentTime = videoPosition;
			e.duration = 0;
			e.info = VimeoPlayingState.PAUSE;
			dispatchEvent(e);
			event_timer.stop();
			event_timer.reset();
			if (jsInterface) {
				var event:JsEvent = new JsEvent(JsEvent.PAUSE);
				event.position = videoPosition;
				jsInterface.fireEvent(event);
			}
			//Logger.info('... paused')
		}
		
		/**
		 * Seek to specific loaded time in video (in seconds)
		 */
		public function seekTo(time:Number):void {
			if (time < 0) time = 0;
			if (videoDuration && time > videoDuration) time = videoDuration;
			
			var wasPlaying:Boolean = isPlaying;
			if (!wasPlaying) {
				moogaloop.api_play();
			}
			moogaloop.api_seekTo(time);
			if (!wasPlaying) {
				moogaloop.api_pause();
			}
			if (enablePlayheadEvent)
			{
				var vimeoPlayEvent:VimeoEvent = new VimeoEvent(VimeoEvent.STATUS);
				vimeoPlayEvent.currentTime = time;
				vimeoPlayEvent.duration = videoDuration;
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
		public function loadVideo(id:*):void {
			moogaloop.api_loadVideo(id);
			isDurationChanged = true;
			
			// reset duration property
			_duration = 0;
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
			//Logger.info('setSize('+w+', '+h+')');
			moogaloop.api_setSize(w, h);
			//Logger.info('moogaloop: '+moogaloop);
			//Logger.info('moogaloop.api_setSize: '+moogaloop.api_setSize);
			
			//Logger.info('moogaloop size', moogaloop.width, moogaloop.height)
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
			
			moogaloop.api_addEventListener('onSeek', handleSeek, false, 0, true);
			removeEventListener(MouseEvent.CLICK, handleUIClick);
			stage.removeEventListener(FullScreenEvent.FULL_SCREEN, handleFullscreenChanged);
			
        }
		//--------------------------------------------------------------------------
        //
        //  Methods
        //
        //--------------------------------------------------------------------------
		private function setDimensions(w:int, h:int):void {
			_player_width  = w;
			_player_height = h;
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
				
				
				
				//
				
				//Defaultvars.getInstance().vars.embed_settings.color   
				//embedSettings = defaultVars.vars.embed_settings; 
				
				// set references to moogaloop UI elements
				_ui = new VimeoPlayerUI(this); 
				_video_manager = getInstanceByClass(moogaloop, 'VideoManager');
				_video = videoManager.getChildAt(0).getChildAt(0);
				overlay = videoManager.getChildAt(0).getChildAt(1);
				moogaloop.api_enableHDEmbed(); 
//				setSize(player_width, player_height);

				enableSeekEvents();
				
				if (jsInterface) {
					var event:JsEvent = new JsEvent(JsEvent.MOOGALOOP_READY); 
					event.duration = videoDuration;
					event.moogaloopUrl = url;
					jsInterface.fireEvent(event);
				}
				
				var vimeoEvent:VimeoEvent = new VimeoEvent(VimeoEvent.PLAYER_LOADED);
				vimeoEvent.duration = 0;
				vimeoEvent.info = "";
				dispatchEvent(vimeoEvent);
			
			}
		}
		
		//deprecated: can't access moogaloop applicationDomain anymore..?
		/*
		public function get defaultVars():Object
		{
			//Logger.info('get defaultVars', loader.contentLoaderInfo.applicationDomain)
			return loader.contentLoaderInfo.applicationDomain.getDefinition("com.as3.classes::DefaultVars").getInstance();
		}
		 */
		/**
		 * dispatch Event for the VideoStatus
		 * @param	e
		 */
		private function handleEventTimer(e:TimerEvent):void
		{ 
			var isPlaying:Boolean = true;
			var newCurrentTime:Number = videoPosition;
			//Check if the currentTime Value already exists
			if (oldCurrentTime == newCurrentTime && oldCurrentTime != 0)
			{
				completeCurrentTimeCounter++;
			}
				else if(newCurrentTime == 0)
			{
				var vimeoEvent:VimeoEvent = new VimeoEvent(VimeoEvent.STATUS);
				vimeoEvent.currentTime = newCurrentTime;
				vimeoEvent.duration = videoDuration;
				vimeoEvent.info = VimeoPlayingState.BUFFERING;
				dispatchEvent(vimeoEvent);
				isPlaying = false;
			}
			
			// It is almost impossible that the currentTime has the same value MAX_REPEAT_SAME_CURRENT_TIME times,
			// when it is playing. So I think the video playing is completed
			if (!isPlaying && (completeCurrentTimeCounter >= MAX_REPEAT_SAME_CURRENT_TIME) )
			{
				var vimeoEventComplete:VimeoEvent = new VimeoEvent(VimeoEvent.STATUS);
				vimeoEventComplete.currentTime = videoDuration;
				vimeoEventComplete.duration = videoDuration;
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
				vimeoPlayEvent.currentTime = videoPosition;
				vimeoPlayEvent.duration = videoDuration;
				vimeoPlayEvent.info = VimeoPlayingState.PLAYING;
				dispatchEvent(vimeoPlayEvent);
			}
			
		}
		
		public var mouseMoveEnabled:Boolean = true;
		/**
		 * Fake the mouse move/out events for Moogaloop
		 */
		private function mouseMove(e:MouseEvent):void { 
			if (!mouseMoveEnabled) {
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
		
		private function redrawMask():void { 
			with( player_mask.graphics ) {
				beginFill(0x000000, 1);
				drawRect(container.x, container.y, playerWidth, playerHeight);
				endFill();
			}
		}
		
		
	}
}