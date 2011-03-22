package org.mindpirates.websubs
{
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	import flash.geom.Transform;
	import flash.text.AntiAliasType;
	import flash.text.StyleSheet;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	
	/** 
	 * @author Jovica Aleksic
	 */
	public class SubtitleTextField extends TextField
	{ 
		private var _fontSize:Number = 10;
		
		public function SubtitleTextField(config:Params)
		{
			super();
			
			var textFormat:TextFormat = new TextFormat();
			textFormat.align = TextFormatAlign.CENTER; 
			mouseEnabled = false;
			selectable = false;
			embedFonts = true;  
			multiline = true; 
			defaultTextFormat = textFormat;
			antiAliasType = AntiAliasType.ADVANCED;  
			filters = [new DropShadowFilter(2,45,0,0.5,2,2), new GlowFilter(0,1,3,3,4)]; 
			
			wordWrap = true;
			_fontSize = config.fontSize;
			
			updateStyles()    
		}
		private function updateStyles():void
		{
			var _text:String = htmlText;
			
			var ss:StyleSheet = new StyleSheet();
			ss.setStyle('.subtitle', {
				color:'#FFFFFF',
				fontSize: _fontSize,
				fontFamily:new _DejaVu().fontName
			});
			ss.setStyle('i', {
				color:'#FFFFFF',
				fontSize: _fontSize,
				fontFamily:new _DejaVuOblique().fontName
			});
			ss.setStyle('strong', {
				color:'#FFFFFF',
				fontSize: _fontSize,
				fontWeight: 'bold',
				fontFamily:new _DejaVuBold().fontName,
				display: 'inline'
			});  
			
			styleSheet = ss;	
			
			htmlText = _text;
		}
		public function set fontSize(value:Number):void
		{
			if (value < 1) {
				value = 1;
			}
			_fontSize = value;
			updateStyles();
		}
		public function get fontSize():Number
		{
			return _fontSize;
		}
		public function set scale(value:Number):void
		{ 
			var matrix:Matrix = transform.matrix; 
			if (value == 1) {
				matrix.identity();				
			} 
			else {
				matrix.scale( value, value );
			}
			transform.matrix = matrix;
		}
	}
}