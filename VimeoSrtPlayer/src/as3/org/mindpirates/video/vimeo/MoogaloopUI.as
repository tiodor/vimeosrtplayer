package org.mindpirates.video.vimeo
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	import org.mindpirates.video.interfaces.IVideoPlayerUI;
	import org.osflash.thunderbolt.Logger;
	
	public class MoogaloopUI implements IVideoPlayerUI
	{
		private var _playbar:DisplayObject;
		private var _playButton:DisplayObject;
		private var _fullscreen_button:SimpleButton;
		private var _vimeo_logo:DisplayObject;
		private var _timeline:DisplayObject;
		private var _volumeSlider:DisplayObject; 
		
		public function MoogaloopUI(moogaloop:Object)
		{ 
			if ( !(moogaloop as DisplayObjectContainer) ) {
				throw new Error('MoogaloopUI failed - '+moogaloop+' is not a DisplayObjectContainer');
			}
			_playbar = (moogaloop as DisplayObjectContainer).getChildByName('playbar');
			_playButton = (_playbar as Object).playButton; 					
			_vimeo_logo = (_playbar as Object).vimeo_logo;
			_timeline = (_playbar as Object).timeline;
			_volumeSlider = (_playbar as Object).volume;
			_fullscreen_button = (_playbar as Object).fullscreen_button;
			 
			  
		}
	 
		public function get playButton():DisplayObject
		{
			return _playButton;
		}
		
		public function get fullscreenButton():DisplayObject
		{
			return _fullscreen_button;
		}
		
		public function get logo():DisplayObject
		{
			return _vimeo_logo;
		}
		
		public function get playbar():DisplayObjectContainer
		{
			return _playbar as DisplayObjectContainer;
		}
		
		public function get volumeSlider():DisplayObjectContainer
		{
			return _volumeSlider as DisplayObjectContainer;
		}
	}
}