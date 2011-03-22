package org.mindpirates.video.vimeo
{ 
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;
	
	import org.mindpirates.websubs.VimeoAuth;
	import org.mindpirates.websubs.WebsubsJsInterface;
	import org.osflash.thunderbolt.Logger;
	
	public class MoogaloverWrapper extends MoogaloopWrapper
	{
		public function MoogaloverWrapper(info:LoaderInfo, w:int, h:int, js:WebsubsJsInterface)
		{ 
			super(info, w, h, js);
		} 
		override public function get playerUrl():String
		{ 
			return MOOGALOOP_URL 
				+ '?fp_version=10'
				+ '&oauth_key=' + VimeoAuth.CONSUMER_KEY
				+ '&clip_id=' + (clip_id || '')
				+ '&width=' + _playerWidth 
				+ '&height=' + _playerHeight 
				+ '&fullscreen=1' 
				+ (loaderParams.queryParams ? '&'+loaderParams.queryParams : ''); 
			 
		} 
		
		 
		override public function get videoManager():Object
		{ 
			Logger.info('get videoManager()')
			if (!_videoManager) {  
				for (var i:int=0,num:int=(moogaloop as DisplayObjectContainer).numChildren; i<num; i++) {
					var o:DisplayObject = moogaloop.getChildAt(i); 
				 
					if (o.toString() == '[object VideoController]') {
						_videoManager = moogaloop.getChildAt(i);
					}
				}
			}
			return _videoManager as Object;
		}
		 
		override internal function handleMoogaloopReady():void
		{ 
			Logger.info('moogaloop: '+moogaloop);
			super.handleMoogaloopReady(); 
		}
		override internal function createUI():void
		{
			_ui = new MoogaloverUI(moogaloop); 	
		}
	}
}