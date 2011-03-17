package de.derhess.video.vimeo
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	
	import org.mindpirates.video.interfaces.IVideoPlayerUI;
	import org.osflash.thunderbolt.Logger;
	  
	/**
	 * 
	 * References to some UI elements of the moogaloop playbar.
	 * @author Jovica Aleksic [mindpirates.org, Deutschland]
	 * 
	 */
	public class VimeoPlayerUI implements IVideoPlayerUI
	{ 
		private var _playbar:Object;
		private var _playButton:Sprite; // :PlayButton
		private var _fullscreen_button:SimpleButton; // :FullscreenButton
		private var _tinybutton:Sprite; // :PlayButton
		private var _vimeo_logo:SimpleButton; // :BrandingButton
		private var _timeline:Sprite; // :Timeline
		private var _volumeSlider:Sprite; // :Volume
		public function VimeoPlayerUI(player:VimeoPlayer)
		{
			_playbar = player.moogaloop.getChildByName('playbar');
			_playButton = _playbar.playButton; 
			_fullscreen_button = _playbar.fullscreen_button;
			_tinybutton = _playbar.tinybutton; 
			_vimeo_logo = _playbar.vimeo_logo;
			_timeline = _playbar.timeline;
			_volumeSlider = _playbar.volume;
		}
		public function get fullscreenButton():DisplayObject
		{
		//	Logger.info('_fullscreen_button: '+_fullscreen_button)
			return _fullscreen_button;
		}
		public function get logo():DisplayObject
		{
			//Logger.info('_vimeo_logo: '+_vimeo_logo)
			return _vimeo_logo;
		}
		public function get playbar():DisplayObjectContainer
		{
			//Logger.info('_playbar: '+_playbar)
			return _playbar as DisplayObjectContainer;
		}
		public function get playButton():DisplayObject
		{
			//Logger.info('_playButton: '+_playButton)
			return _playButton;
		}
		public function get volumeSlider():DisplayObjectContainer
		{
			//Logger.info('_volumeSlider: '+_volumeSlider)
			return _volumeSlider;
		}
		
		
	}
}