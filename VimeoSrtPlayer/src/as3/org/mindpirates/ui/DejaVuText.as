package org.mindpirates.ui
{
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import org.osflash.thunderbolt.Logger;
	
	public class DejaVuText extends TextField
	{
		private var _color:uint = 0xFFFFFF;
		public function DejaVuText()
		{
			super();
			embedFonts = true;
			autoSize = TextFieldAutoSize.LEFT;
			antiAliasType = AntiAliasType.ADVANCED;
			defaultTextFormat = new TextFormat(new _DejaVu().fontName, 11, _color, false, false, false, null, null, TextFormatAlign.CENTER);
		}
		public function set color(value:uint):void
		{
			_color = value;
			var fmt:TextFormat = defaultTextFormat;
			fmt.color = value;
			defaultTextFormat = fmt;
			setTextFormat(fmt);
		}
		public function get color():uint
		{
			return _color;
		}
	}
}