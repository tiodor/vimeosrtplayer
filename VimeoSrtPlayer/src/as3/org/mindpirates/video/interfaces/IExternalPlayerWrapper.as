package org.mindpirates.video.interfaces
{
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	
	public interface IExternalPlayerWrapper extends IEventDispatcher
	{ 
		function get playerUrl():String;
		function loadPlayer():void;
		function handlePlayerLoadComplete(e:Event):void;
		function handlePlayerLoadError(e:IOErrorEvent):void;
	}
}