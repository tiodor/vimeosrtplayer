package de.derhess.video.vimeo
{
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	  
	/**
	 * 
	 * References to some UI elements of the moogaloop playbar.
	 * @author Jovica Aleksic [mindpirates.org, Deutschland]
	 * 
	 */
	public class VimeoPlayerUI
	{ 
		public var playbar:Object;
		public var playButton:Sprite; // :PlayButton
		public var fullscreen_button:SimpleButton; // :FullscreenButton
		public var tinybutton:Sprite; // :PlayButton
		public var vimeo_logo:SimpleButton; // :BrandingButton
		public var timeline:Sprite; // :Timeline
		public var volume:Sprite; // :Volume
		public function VimeoPlayerUI(player:VimeoPlayer)
		{
			playbar = player.moogaloop.getChildByName('playbar');
			playButton = playbar.playButton; 
			fullscreen_button = playbar.fullscreen_button;
			tinybutton = playbar.tinybutton; 
			vimeo_logo = playbar.vimeo_logo;
			timeline = playbar.timeline;
			volume = playbar.volume;
		}
	}
}