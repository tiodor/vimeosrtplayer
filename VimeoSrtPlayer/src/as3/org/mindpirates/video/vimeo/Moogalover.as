package org.mindpirates.video.vimeo
{
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;
	import flash.system.Security;
	
	import org.mindpirates.subtitles.JSInterface;
	import org.mindpirates.subtitles.VimeoAuth;

	[SWF(width="450", height="225")]
	public class Moogalover extends Sprite
	{
		
		public static const MOOGALOOP_URL:String = "http://api.vimeo.com/moogaloop_api.swf"; 
		
		public var loader:Loader;
		
		public function Moogalover(info:LoaderInfo, w:int, h:int, jsInterface:JSInterface=null)
		{
		}
		
		private function loadPlayer():void
		{  
			var clip_id:String;
			var w:int,h:int;
			var url:String;
			var loaderParams:Object;
			
			Security.allowDomain("*");
			Security.loadPolicyFile("http://vimeo.com/moogaloop/crossdomain.xml"); 
			url = MOOGALOOP_URL + "?fp_version=10&oauth_key="+VimeoAuth.CONSUMER_KEY+"&clip_id="+clip_id + "&width=" + w + "&height=" + h + "&fullscreen=1" + (loaderParams.queryParams ? '&'+loaderParams.queryParams : '');
			
			loader = new Loader(); 
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, handlePlayerLoadComplete, false, 0, true);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, handlePlayerLoadError, false, 0, true);
			loader.load(new URLRequest(url));
			/*
			addEventListener(VimeoEvent.STATUS, handleStatus, false, 0, true); 
			addEventListener(Event.ADDED_TO_STAGE, handleAddedToStage, false, 0, true);
			addEventListener(MouseEvent.CLICK, handleUIClick, true, 0, true);
			addEventListener(MouseEvent.MOUSE_DOWN, handleUIMouseDown, true, 0, true);
			addEventListener(MouseEvent.MOUSE_UP, handleUIMouseUp, true, 0, true);
			*/
		}
		private function handlePlayerLoadComplete(e:Event):void
		{
			
		}
		private function handlePlayerLoadError(e:Event):void
		{
			
		}
	}
}