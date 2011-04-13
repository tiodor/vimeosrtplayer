package org.mindpirates.websubs.ui
{
	import de.derhess.video.vimeo.VimeoPlayer;
	
	import fl.controls.Button;
	import fl.controls.ComboBox;
	import fl.data.DataProvider;
	
	import flash.display.Graphics;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.net.navigateToURL;
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
	
	public class ShareScreen extends Screen
	{
		public static const TYPE:String = 'share';
		
		private var comboLang:ComboBox;
		private var comboShowLangs:ComboBox;
		public function ShareScreen(layer:SubtitlesLayer)
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
				filters: [new DropShadowFilter(2,45,0,0.5,2,2), new GlowFilter(0,1,3,3,4)],
				applyTo: function(target:*):void {
					for (var p:String in this) {
						if (typeof this[p] != 'function') {
							target[p] = this[p];
						}
					}
				}
			}; 
			
			var labelFormat:TextFormat = new TextFormat();			
			labelFormat = new TextFormat();
			labelFormat.color = 0xffffff;
			labelFormat.align = TextFormatAlign.CENTER; 
			labelFormat.font = new _DejaVu().fontName;
			labelFormat.size = 12;
			
			
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
			titleField.text = 'Share PROBLEMA';
			contents.addChild( titleField );
			*/
			
			var button_facebook:RoundedButton = new RoundedButton(0xffffff, (subtitles.player as VimeoPlayer).color, 0x000000, 0xffffff);
			button_facebook.data = {type:'facebook'};
			button_facebook.y = 0//titleField.y + titleField.height + 5;	
			button_facebook.icon = logo_fb_14;   
			button_facebook.text = "Share on Facebook";
			button_facebook.width = 160;
			button_facebook.height = 26;
			button_facebook.addEventListener(MouseEvent.CLICK, handleButtonClick, false, 0, true);
			contents.addChild(button_facebook);
			
			
			var button_twitter:RoundedButton = new RoundedButton(0xffffff, (subtitles.player as VimeoPlayer).color, 0x000000, 0xffffff);	
			button_twitter.data = {type:'twitter'};
			button_twitter.icon = logo_tw_14;   
			button_twitter.text = "Share on Twitter";
			button_twitter.width = 160;
			button_twitter.height = 26;
			button_twitter.y = button_facebook.y + button_facebook.height + 5;
			button_twitter.addEventListener(MouseEvent.CLICK, handleButtonClick, false, 0, true);
			contents.addChild(button_twitter);
			
			redraw();
		}
		
		private function handleButtonClick(e:MouseEvent):void
		{
			var site:String = e.target.data.type;
			var shareUrl:String;
			var maxLength:Number;
			switch (site)
			{
				case "facebook":
					maxLength = 255;
					break;
				case "twitter":
					maxLength = 140;
					break;
				default:
					return;
					break;
			}
			
			var link:String = subtitles.config.shareUrl;
			var text:String = 'PROBLEMA - Who are we in the 21st Century?';
			
			var availableTextLength:Number = maxLength - (link.length + 1);
			if (text.length > availableTextLength)
			{
				text = text.substr(0, (availableTextLength - 3)) + '...';
			}
			
			switch (site) {
				case 'facebook':  
					shareUrl = 'http://www.facebook.com/sharer.php?u='+encodeURIComponent(link)+'&t='+encodeURIComponent(text);
					break;
				case 'twitter': 
					shareUrl = 'http://twitter.com/share?text=' + encodeURIComponent(text) + '&url=' + encodeURIComponent(link);
					break;
			}
			
			Logger.info(site+' -> '+shareUrl);
			var urlRequest:URLRequest = new URLRequest(shareUrl);  
			navigateToURL(urlRequest, '_blank');
			
			var t:Timer = new Timer(2000,1);
			t.addEventListener(TimerEvent.TIMER_COMPLETE, hide, false, 0, true);
			t.start();
		}
		
		private function handleTwitterClick(e:MouseEvent):void
		{
			 
		}
	}
}