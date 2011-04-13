package org.mindpirates.websubs.ui
{
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import org.osflash.thunderbolt.Logger;

	public class RoundedButton extends RoundedTextArea
	{
		private var buttonDecorator:ButtonDecorator;
		private var txtUpClr:uint;
		private var txtOverClr:uint;
		private var _iconImage:DisplayObject;
		public var data:Object;
		public function RoundedButton(clrUp:uint, clrOver:uint, txtColorUp:uint, txtColorOver:uint)
		{
			super();  
			bgColor = clrUp;
			txtUpClr = txtColorUp;
			txtOverClr = txtColorOver;
			buttonDecorator = new ButtonDecorator(this, clrOver);
			addEventListener(MouseEvent.ROLL_OVER, handleRollOver, false, 0, true);
			addEventListener(MouseEvent.ROLL_OUT, handleRollOut, false, 0, true);
			handleRollOut(null);
			
			field.wordWrap = false;
			field.autoSize = TextFieldAutoSize.LEFT;
			field.selectable = false;
			
			var buttonFormat:TextFormat = new TextFormat();	 
			buttonFormat.font = new _DejaVuBold().fontName;
			buttonFormat.bold = true;
			buttonFormat.size = 11;
			buttonFormat.align = TextFormatAlign.LEFT;
			field.defaultTextFormat = buttonFormat;
		} 
		
		private function handleRollOver(e:MouseEvent):void
		{ 
			var transform:ColorTransform = new ColorTransform();
			transform.color = txtOverClr;
			field.transform.colorTransform = transform;		
		}
		private function handleRollOut(e:MouseEvent):void
		{ 
			var transform:ColorTransform = new ColorTransform();
			transform.color = txtUpClr;
			field.transform.colorTransform = transform;
		}
		public function set icon(value:Class):void
		{
			_iconImage = addChild( new value() ); 
			 
			display();
		 
		} 
		override public function display(e:Event=null):void
		{ 
			
			field.width = field.textWidth + 5;
			field.height = field.textHeight + 5 ;
			field.x = (_width-field.width)/2;
			
			if (_iconImage) {
				/*
				_iconImage.x = _iconImage.y; 
				field.x = _iconImage.x + _iconImage.width;
				field.width -= field.x;
				*/
				var d:Number = (_width - (field.width + _iconImage.width))/2;
				_iconImage.x = d;
				_iconImage.y = (_height - _iconImage.height) / 2;  
				field.x = _iconImage.x +_iconImage.width;
				 
			}
			
			var g:Graphics = background.graphics;
			g.clear(); 
			g.beginFill(bgColor);
			g.drawRoundRect(0, 0, _width, _height, CORNER_RADIUS);		
		}
		
	}
}