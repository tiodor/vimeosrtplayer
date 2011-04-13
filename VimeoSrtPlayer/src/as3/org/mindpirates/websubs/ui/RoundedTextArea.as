package org.mindpirates.websubs.ui
{
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	
	import org.osflash.thunderbolt.Logger;
	
	public class RoundedTextArea extends Sprite
	{
		
		public static const CORNER_RADIUS:int = 10;
		
		// display objects
		public var background:Sprite;
		public var field:TextField;
		public var padding:Number = 5;
		// properties 
		internal var _width:Number = 0;
		internal var _height:Number = 0;
		public var bgColor:Number = 0xFFFFFF;
		
		public function RoundedTextArea()
		{
			super();
			
			background = new Sprite();
			field = new TextField();
			field.embedFonts = true;
			field.antiAliasType = AntiAliasType.ADVANCED; 
			field.wordWrap = true;			
			field.x = padding;
			field.y = padding; 
			addChild(background);
			addChild(field);
			 
			addEventListener(Event.ADDED_TO_STAGE, display, false, 0, true);
		}
		
		
		public function set text(newText:String):void
		{
			field.text = newText;  
			display();
		}
		
		public function get text():String
		{
			return field.text;
		}
		 
		override public function set width(value:Number):void
		{
			_width = value;
			 
			display();
		}
		override public function set height(value:Number):void
		{
			_height = value; 
			display();
		}  
		
		public function display(e:Event=null):void
		{ 
			field.width = _width - padding;
			field.height = _height - padding;
			
			var g:Graphics = background.graphics;
			g.clear(); 
			g.beginFill(bgColor);
			g.drawRoundRect(0, 0, _width, _height, CORNER_RADIUS);
		}
		
	}
}