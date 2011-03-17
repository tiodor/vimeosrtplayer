package org.mindpirates.video.vimeo
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	
	import org.mindpirates.video.interfaces.IVideoPlayerUI;
	import org.osflash.thunderbolt.Logger;
	
	public class MoogaloverUI implements IVideoPlayerUI
	{
		
		private var _playbar:DisplayObject;
		private var _playButton:DisplayObject;
		private var _fullscreen_button:Sprite;
		private var _vimeo_logo:DisplayObject;
		private var _timeline:DisplayObject;
		private var _volumeSlider:DisplayObject; 
		
		
		 
		/*
		time 17:55:11.948 :: moogaloop: [object LoopyAPI]
		time 17:55:11.949 :: child 0.: [object BackgroundController]
		time 17:55:11.949 :: child 1.: [object VideoController]
		time 17:55:11.950 :: child 2.: [object ContextMenuController]
		time 17:55:11.950 :: child 3.: [object VideoInfoController]
		time 17:55:11.951 :: child 4.: [object OverlayController]
		time 17:55:11.952 :: child 5.: [object VideoControlsController]
		time 17:55:11.952 :: child 6.: [object BaseView]
		
		time 18:07:52.685 :: videoControlsController.getChildAt(0): [object PlayPauseButton]
		time 18:07:52.686 :: videoControlsController.getChildAt(1): [object ControlBarView]
		time 18:07:52.687 :: videoControlsController.getChildAt(2): [object VideoScrubberView]
		time 18:07:52.688 :: videoControlsController.getChildAt(3): [object VolumeScrubberView]
		time 18:07:52.688 :: videoControlsController.getChildAt(4): [object FullscreenButton]
		time 18:07:52.689 :: videoControlsController.getChildAt(5): [object VimeoButton]
		time 18:07:52.690 :: videoControlsController.getChildAt(6): [object HDButton]
		
		time 19:17:13.695 :: videoController.getChildAt(0): [object BaseView]
		time 19:17:13.695 :: videoController.getChildAt(1): [object VideoView]
		*/
		
		public function MoogaloverUI(moogaloop:Object)
		{
			var videoControlsController:DisplayObjectContainer;
			var videoControlsView:DisplayObjectContainer;
			
			var videoController:DisplayObjectContainer;
			var baseView:DisplayObjectContainer;
			var videoView:DisplayObjectContainer;
			
			var i:int=0;
			var t:int;
			var child:DisplayObjectContainer;
			
			// find top level containers
			for (i=0,t=moogaloop.numChildren; i<t; i++) {
				child = moogaloop.getChildAt(i) as DisplayObjectContainer;
				switch ( child.toString() ) {
					case '[object VideoController]':
						videoController =  child;
						break; 
					case '[object VideoControlsController]':
						videoControlsController = child;
						videoControlsView = videoControlsController.getChildAt(1) as DisplayObjectContainer;
						break;
				}
			}
			for (i=0,t=videoController.numChildren; i<t; i++) {
				child = videoController.getChildAt(i) as DisplayObjectContainer;
				switch ( child.toString() ) {
					case '[object BaseView]':
						baseView = child;
						break;  
					case '[object VideoView]':
						videoView = child;
						break;  
				}
			}
			for (i=0,t=videoView.numChildren; i<t; i++) {
				child = videoView.getChildAt(i) as DisplayObjectContainer;
				//Logger.info('videoView.getChildAt('+i+') = '+child)
			}
			
			// find nested UI elements
			for (i=0,t=videoControlsView.numChildren; i<t; i++) {
				child = videoControlsView.getChildAt(i) as DisplayObjectContainer;
				switch ( child.toString() ) {
					case '[object PlayPauseButton]':
						_playButton = child;
						break;
					case '[object FullscreenButton]':
						_fullscreen_button = child as Sprite;
						break;
					case '[object VideoScrubberView]':
						_timeline = child;
						break;
					case '[object VolumeScrubberView]':
						_volumeSlider = child;
						break;
				}
			} 
			/*Logger.info('_playButton: '+ _playButton);
			Logger.info('_fullscreen_button: '+ _fullscreen_button);
			Logger.info('_timeline: '+ _timeline);
			Logger.info('_volumeSlider: '+ _volumeSlider);*/
		}
		
		public function get playButton():DisplayObject
		{
			if (!_playButton) throw new Error('_playButton is '+_playButton);
			return _playButton;
		}
		
		public function get fullscreenButton():DisplayObject
		{
			if (!_fullscreen_button) throw new Error('_fullscreen_button is '+_playButton);
			return _fullscreen_button;
		}
		
		public function get logo():DisplayObject
		{ 
			return null;
		}
		
		public function get playbar():DisplayObjectContainer
		{
			if (!_playbar) throw new Error('_playbar is '+_playButton);
			return _playbar as DisplayObjectContainer;
		}
		
		public function get volumeSlider():DisplayObjectContainer
		{
			if (!_volumeSlider) throw new Error('_volumeSlider is '+_playButton);
			return _volumeSlider as DisplayObjectContainer;
		}
	}
}