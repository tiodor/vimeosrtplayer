package org.mindpirates.ui
{
	import org.osflash.thunderbolt.Logger;

	public class RadioTextButton extends TextButton
	{
		public var radio:RadioCheck;
		private var _selectedColor:uint = 0xFFFFFF;
		private var _defaultColor:uint = 0xFFFFFF;
		public function RadioTextButton(txt:String="")
		{
			super(txt);
			radio = new RadioCheck();
			addChild(radio);
			draw();
		}
		
		override public function draw():void
		{    
			if (!radio) {
				return;
			}
			width = 2 * padding + radio.width + textField.width;
			height = 2 * padding + textField.height;
			
			radio.x = padding;
			radio.y = (height - radio.height) / 2;
			 
			textField.x = radio.width/2 + (width - textField.width)/2;
			textField.y = (height - textField.height)/2 + 0.5;
		}
		
		override public function set selected(value:Boolean):void
		{ 
			radio.selected = value;
			if (value) {
				textField.color = selectedColor;
			}
			else {
				textField.color = defaultColor;
			}
		}
		override public function get selected():Boolean
		{ 
			return radio.selected;
		}
		
		public function set selectedColor(value:uint):void
		{
			_selectedColor = value;
			if (selected) {
				textField.color = value;
			}
		}
		
		public function get selectedColor():uint
		{
			return _selectedColor;
		}
		
		public function set defaultColor(value:uint):void
		{
			_defaultColor = value;
			if (!selected) {
				textField.color = value;
			}
		}
		
		public function get defaultColor():uint
		{
			return _defaultColor;
		}
	}
}