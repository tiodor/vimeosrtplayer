package org.mindpirates.websubs.ui
{
	import flash.events.Event;

	public interface IScreen
	{
		function show(e:Event=null):void;
		function hide(e:Event=null):void;
	}
}