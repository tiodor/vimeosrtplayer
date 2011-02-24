package org.mindpirates.ui
{
	import org.osflash.thunderbolt.Logger;

	public class TextButton extends RoundedButton
	{
		public var textField:DejaVuText;
		private var _padding:Number = 5; 
		public function TextButton(txt:String="")
		{
			super(10,10);
			textField = new DejaVuText();
			addChild( textField );
			overSprite.color = 0x666666;
			text = txt
		}
		
		public function set text(value:String):void
		{
			textField.text = value;
			draw();
		}
		public function get text():String
		{
			return textField.text;
		}
		public function set padding(value:Number):void
		{
			_padding = value;
			draw();
		}
		public function get padding():Number
		{
			return _padding;
		}
		public function draw():void 
		{
			width = 2 * _padding + textField.width;
			height = 2 * _padding + textField.height;
			textField.x = (width - textField.width)/2;
			textField.y = (height - textField.height)/2;
		}
	}
}