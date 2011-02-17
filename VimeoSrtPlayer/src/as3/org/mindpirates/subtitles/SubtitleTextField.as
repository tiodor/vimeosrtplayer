package org.mindpirates.subtitles
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
		
		public function SubtitleTextField(config:SubtitlesConfig)
		{
			super();
			
			var textFormat:TextFormat = new TextFormat();
			textFormat.align = TextFormatAlign.CENTER; 
			
			selectable = false;
			embedFonts = true;  
			multiline = true; 
			defaultTextFormat = textFormat;
			antiAliasType = AntiAliasType.ADVANCED;  
			filters = [new DropShadowFilter(2,45,0,0.5,2,2), new GlowFilter(0,1,1,1,2)]; 
			
			
			var ss:StyleSheet = new StyleSheet();
			ss.setStyle('.subtitle', {
				color:'#FFFFFF',
				fontSize:config.fontSize,
				fontFamily:new _DejaVu().fontName
			});
			ss.setStyle('i', {
				color:'#FFFFFF',
				fontSize:config.fontSize,
				fontFamily:new _DejaVuOblique().fontName
			});
			ss.setStyle('strong', {
				color:'#FFFFFF',
				fontSize: config.fontSize,
				fontWeight: 'bold',
				fontFamily:new _DejaVuBold().fontName,
				display: 'inline'
			});  
		
			styleSheet = ss;    
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