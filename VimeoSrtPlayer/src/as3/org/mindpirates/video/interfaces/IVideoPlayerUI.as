package org.mindpirates.video.interfaces
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;

	public interface IVideoPlayerUI
	{
		function get playButton():DisplayObject;
		function get fullscreenButton():DisplayObject;
		function get logo():DisplayObject;
		function get playbar():DisplayObjectContainer;
		function get volumeSlider():DisplayObjectContainer;
	}
}