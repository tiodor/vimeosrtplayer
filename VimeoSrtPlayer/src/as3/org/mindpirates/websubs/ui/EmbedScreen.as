package org.mindpirates.websubs.ui
{
	import com.greensock.TweenLite;
	
	import de.derhess.video.vimeo.VimeoPlayer;
	
	import fl.controls.ComboBox;
	import fl.data.DataProvider;
	
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.system.System;
	import flash.text.AntiAliasType;
	import flash.text.StyleSheet;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.utils.Timer;
	import flash.xml.XMLNode;
	
	import org.mindpirates.websubs.LocalizationXML;
	import org.mindpirates.websubs.SubtitlesLayer;
	import org.osflash.thunderbolt.Logger;
	
	public class EmbedScreen extends Screen
	{
		public static const TYPE:String = 'embed';
		
		private var comboLang:ComboBox;
		private var comboShowLangs:ComboBox;
		private var codeArea:RoundedTextArea; 
		
		private var copyButton:RoundedButton;
		
		public function EmbedScreen(layer:SubtitlesLayer)
		{
			super(layer);
			type = TYPE; 
			
			
			createLayout();
		}
		private function createLayout():void
		{
			//--------------------------------------------------------
			//
			// DEFAULT VALUES
			//
			//-------------------------------------------------------- 
			
			var defaultTextProps:Object = {
				autoSize: TextFieldAutoSize.LEFT,
				mouseEnabled: false,
				selectable: false,
				embedFonts: true,  
				multiline: true, 			
				antiAliasType: AntiAliasType.ADVANCED,  
				/*filters: [new DropShadowFilter(2,45,0,0.5,2,2), new GlowFilter(0,1,3,3,4)],*/
				applyTo: function(target:*):void {
					for (var p:String in this) {
						if (typeof this[p] != 'function') {
							target[p] = this[p];
						}
					}
				}
			};
			
			
			var labelFormat:TextFormat = new TextFormat();	 
			labelFormat.color = 0xffffff;
			labelFormat.align = TextFormatAlign.CENTER; 
			labelFormat.font = new _DejaVu().fontName;
			labelFormat.size = 12;
			
			var codeFormat:TextFormat = new TextFormat(); 
			codeFormat.color = 0x000000; 
			codeFormat.font = new _typewriter().fontName;
			codeFormat.size = 10;
			
			var vspacing:Number = 10;
			 
			//--------------------------------------------------------
			//
			// TITLE TEXT
			//
			//-------------------------------------------------------- 
			/*
			var headerFormat:TextFormat = new TextFormat();	 
			headerFormat.color = 0xffffff;
			headerFormat.align = TextFormatAlign.LEFT; 
			headerFormat.font = new _DejaVuBold().fontName;
			headerFormat.bold = true;
			headerFormat.size = 12;
			
			titleField = new TextField(); 
			titleField.height = 20; 
			titleField.autoSize = TextFieldAutoSize.LEFT;
			titleField.embedFonts = true;
			titleField.multiline = false; 
			titleField.wordWrap = false;
			titleField.antiAliasType = AntiAliasType.ADVANCED, 
			titleField.defaultTextFormat = headerFormat; 
			titleField.text = 'Embed code generator';
			contents.addChild( titleField );
		 	*/
			 
			//--------------------------------------------------------
			//
			// LANGUAGE SELECTION
			//
			//-------------------------------------------------------- 
			
			var langLabel:TextField = new TextField(); 
			defaultTextProps.applyTo(langLabel); 
			langLabel.defaultTextFormat = labelFormat; 
			langLabel.text = 'Subtitles language: ';
			langLabel.y = 0; //titleField.y + titleField.height + vspacing;
			contents.addChild( langLabel );
			
			comboLang = createCombo();
			comboLang.y = langLabel.y - 2;
			comboLang.addEventListener(Event.CHANGE, handleComboChange, false, 0, true)
			comboLang.x = 150; 
			
			
			//--------------------------------------------------------
			//
			// LANGUAGE MENU
			//
			//-------------------------------------------------------- 
			
			var showLangsLabel:TextField = new TextField(); 
			defaultTextProps.applyTo(showLangsLabel); 
			showLangsLabel.defaultTextFormat = labelFormat; 
			showLangsLabel.text = 'Show language menu:';
			showLangsLabel.y = langLabel.y + langLabel.height + vspacing;
			contents.addChild( showLangsLabel );
			
			comboShowLangs = createCombo();
			comboShowLangs.dataProvider = new DataProvider([{label:'yes',value:true}, {label:'no', value: false}]);
			comboShowLangs.y = showLangsLabel.y - 2;
			comboShowLangs.x = 150; 
			comboShowLangs.addEventListener(Event.CHANGE, handleComboChange, false, 0, true)
			contents.addChild( comboShowLangs );
			 
			//--------------------------------------------------------
			//
			// CODE TEXTAREA
			//
			//-------------------------------------------------------- 
			 
			codeArea = new RoundedTextArea();
			contents.addChild(codeArea);
			codeArea.field.defaultTextFormat = codeFormat;   
			codeArea.width = 250;
			codeArea.height = 80; 
			codeArea.y = showLangsLabel.y + showLangsLabel.height + vspacing; 
			
			//--------------------------------------------------------
			//
			// COPY CODE BUTTON
			//
			//--------------------------------------------------------  
			
			var buttonFormat:TextFormat = new TextFormat();	 
			buttonFormat.font = new _DejaVuBold().fontName;
			buttonFormat.bold = true;
			buttonFormat.size = 11;
			buttonFormat.align = TextFormatAlign.CENTER;
			
			var vimeoColor:uint = (subtitles.player as VimeoPlayer).color;
			var btn:RoundedButton = new RoundedButton( 0xffffff, vimeoColor, 0x000000, 0xffffff );
			btn.width = codeArea.width;
			btn.height = 26;
			btn.x = codeArea.x;
			btn.y = codeArea.y + codeArea.height + vspacing; 
			btn.text = "Copy embed code";  
			contents.addChild(btn);
			btn.addEventListener(MouseEvent.CLICK, handleCopyClick, false, 0, true);
			
			copyButton = btn;
			//--------------------------------------------------------
			//
			// INFO TEXT
			//
			//--------------------------------------------------------  
			
			
			
			redraw();
		}
		private function handleComboChange(e:Event):void
		{
			updateCode();
		}
		
		private function handleCopyClick(e:MouseEvent):void
		{
			System.setClipboard(getCode());
			copyButton.text = 'Copied!';
			var t:Timer = new Timer(2000,1);
			t.addEventListener(TimerEvent.TIMER_COMPLETE, hide, false, 0, true);
			t.start();
		} 
		private function createCombo():ComboBox
		{
			var combo:ComboBox = new ComboBox();    
			combo.setStyle('textPadding',2); 
			 
			var format:TextFormat = new TextFormat()
			format.color = 0xFFFFFF;
			format.bold = false;
			format.font = new _DejaVu().fontName;
			format.size = 12;
			
			combo.dropdown.setRendererStyle("embedFonts",true);
			combo.dropdown.setRendererStyle("textFormat",format);
			combo.dropdown.setRendererStyle("antiAliasType",AntiAliasType.NORMAL);
			
			combo.textField.setStyle("embedFonts",true); 
			combo.textField.setStyle("textFormat",format);
			combo.textField.setStyle("antiAliasType",AntiAliasType.NORMAL);
			combo.textField.textField.autoSize = TextFieldAutoSize.LEFT;
			return combo;			
		}  
		private function populateLanguagesCombo():void
		{ 
			var dp:Array = []; 
			var loc:LocalizationXML = subtitles.localization;
			for each(var lang:String in loc.languages) {
				var item:Object = {
					'lang': lang,			
					'name': loc.getTitleByLang(lang),
					'label': loc.getTitleByLang(lang),
					'description': loc.getDescriptionByLang(lang)
				} 
				dp.push(item); 
			};
			comboLang.dataProvider = new DataProvider(dp); 
			comboLang.selectedIndex = 0;
			contents.addChild(comboLang); 
		}
		override public function show(e:Event=null):void
		{ 
			super.show();
			if (comboLang.dataProvider.length == 0) {
				populateLanguagesCombo();
			}
			comboLang.selectedIndex = 0;
			comboShowLangs.selectedIndex = 0;
			copyButton.text = "Copy embed code";
			updateCode();
		}
		public function updateCode():void
		{  
			codeArea.text = getCode();
		}
		public function getCode():String
		{
			var src:String = subtitles.config.embedUrl; 
			src += '?lang='+comboLang.selectedItem.lang;
			src += '&menu='+(comboShowLangs.selectedItem.value ? '1' : '0');
		 
			return '<iframe src="'+src+'" width="450" height="225" frameborder="0" scrolling="no"></iframe>';
		}
	}
}