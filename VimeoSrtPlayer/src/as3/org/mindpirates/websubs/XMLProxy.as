package org.mindpirates.websubs
{ 
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	//import org.osflash.thunderbolt.Logger;
	
	[Event(name="complete", type="org.mindpirates.websubs.XMLProxy")]
	[Event(name="error", type="org.mindpirates.websubs.XMLProxy")]
	public class XMLProxy extends EventDispatcher
	{
		
		public static const COMPLETE:String = "complete";
		public static const ERROR:String = "error";
		
		internal var _url:String;		
		internal var _xml:XML;
		
		public var noCaching:Boolean;	
		
		public function XMLProxy( url:String = null)
		{   
			
			if (url) {
				_url = url;
				loadXML();
			}
			
		}
		
		public function clone():XMLProxy
		{
			var proxy:XMLProxy = new XMLProxy();
			proxy._url = _url;
			proxy._xml = _xml;
			proxy.noCaching = noCaching;
			return proxy;			
		}
		
		public function get data():XML
		{ 
			return _xml;
		}
		
		public function refresh():void
		{
			loadXML()
		}
		private function log(msg:String):void
		{
			try {
				//Logger.info(msg); 
			}
			catch (e:Error) {
				// ignore
			}
		}
		private function logError(msg:String, ... args):void
		{
			try {
				if (args) {
					//Logger.error(msg, args);	
				}
				else {
					//Logger.error(msg);
				}
				
			}
			catch (e:Error) {
				// ignore
			}
		}
		public function loadXML( url:String=null ):void
		{	
			if (url) {
				_url = url;
			} 
			if (_url == null) {
				logError('XMLProxy: no url set');
				return;
			}
			
			try {
				var __url:String = _url;
				if (noCaching) {
					__url = __url + '?time=' + new Date().getTime();	
				}			
				//Logger.info('XMLProxy['+this+'].__url = '+__url)	
				var request:URLRequest = new URLRequest( __url );
				var loader:URLLoader = new URLLoader();
				loader.addEventListener(Event.COMPLETE, onComplete, false, 0, true);
				loader.addEventListener(IOErrorEvent.IO_ERROR, onError, false, 0, true);
				loader.load( request );
			}
			catch (e:Error) {
				logError( e.message, e );
			}
		}
		
		public function onComplete( event:Event ):void
		{ 
			_xml = new XML( event.target.data );
			dispatchEvent( new Event( XMLProxy.COMPLETE ) );
		}
		
		public function onError( event:Event ):void
		{ 
			dispatchEvent( new Event( XMLProxy.ERROR ) );
		}
		
		public function getValueById(paramName:String):String
		{
			var a:String;
			try
			{
				a =  _xml..param.(@name == paramName).@value;
			}
			catch (e:Error)
			{
				logError(e.message, e); 
			}
			return a;
		}
		
		public function hasValue(paramName:String):Boolean
		{ 
			if (!_xml) {
				logError(this+'['+_url+'].hasValue('+paramName+') failed: XML not loaded yet!');
				return false;
			}
			if (!_xml..param) {
				logError(this+'['+_url+'].hasValue('+paramName+') failed: _xml..param');
				return false;
			}
			try
			{
				var value:String = _xml..param.(@name == paramName).@value; 
				return value != "";
			}
			catch (e:Error)
			{
				logError(this+'['+_url+'].hasValue('+paramName+') failed: '+e.message, e.getStackTrace(), _xml, _xml..param); 
			}
			return false;
		}
		
		public function destroy():void
		{
			_xml = null; 
		}
	}
}