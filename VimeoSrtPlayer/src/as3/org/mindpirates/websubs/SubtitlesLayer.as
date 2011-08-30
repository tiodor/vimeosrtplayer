package org.mindpirates.websubs
{ 
	import com.asual.swfaddress.SWFAddress;
	import com.asual.swfaddress.SWFAddressEvent;
	import com.chewtinfoil.utils.StringUtils;
	import com.greensock.TimelineLite;
	import com.greensock.TweenLite;
	
	import de.derhess.video.vimeo.VimeoEvent;
	import de.derhess.video.vimeo.VimeoPlayer;
	import de.derhess.video.vimeo.VimeoPlayerUI;
	import de.derhess.video.vimeo.VimeoPlayingState;
	
	import fl.controls.Button;
	import fl.controls.ComboBox;
	import fl.data.DataProvider;
	import fl.events.ListEvent;
	
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.ContextMenuEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.filters.DropShadowFilter;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	import flash.utils.Timer;
	import flash.utils.describeType;
	
	import net.stevensacks.preloaders.CircleSlicePreloader;
	
	import nl.inlet42.data.subtitles.SubtitleLine;
	import nl.inlet42.data.subtitles.SubtitleParser;
	import nl.inlet42.data.subtitles.SubtitlesList;
	
	import org.mindpirates.utils.BrowserUtil;
	import org.mindpirates.video.VideoEvent;
	import org.mindpirates.video.interfaces.IVideoPlayer;
	import org.mindpirates.video.interfaces.IVimeoPlayer;
	import org.mindpirates.video.vimeo.MoogaloopWrapper;
	import org.mindpirates.websubs.ui.ButtonDecorator;
	import org.mindpirates.websubs.ui.EmbedScreen;
	import org.mindpirates.websubs.ui.PlayerTooltip;
	import org.mindpirates.websubs.ui.RoundedTextArea;
	import org.mindpirates.websubs.ui.Screen;
	import org.mindpirates.websubs.ui.ShareScreen;
	import org.mindpirates.websubs.ui.TooltipOptions;
	import org.mindpirates.websubs.ui.vimeo.sidedock.EmbedButton;
	import org.mindpirates.websubs.ui.vimeo.sidedock.ShareButton;
	import org.mindpirates.websubs.ui.vimeo.sidedock.SidedockButton;
	import org.osflash.thunderbolt.Logger;
	
	
	/** 
	 * @author Jovica Aleksic
	 */
	
	
	[Event(name="complete",type="flash.events.Event")]
	public class SubtitlesLayer extends Sprite
	{ 
		public var combo:ComboBox;
		public var textField:SubtitleTextField;
		public var player:IVideoPlayer; 
		private var currentSubtitleLine:SubtitleLine;		 
		public var currentScale:Number = 1;  
		public var localization:LocalizationXML;
		private var _config:Params;		
		private var _text:String;
		private var originalSize:Object;
		public var list:SubtitlesList;
		private var timer:Timer;
		
		/* if hideCombo() was called before the list was loaded and the combo created, this flag will store TRUE so we can hide the combo after creation */
		private var _hideCombo:Boolean;
		
		public function SubtitlesLayer(vimeoPlayer:IVideoPlayer)
		{  
			super();
			//Logger.info('new SubtitlesLayer()')
			player = vimeoPlayer;  
			//Logger.info('player: '+player)
			addEventListener(Event.ADDED_TO_STAGE, handleAddedToStage, false, 0, true);
			player.addEventListener(VideoEvent.FULLSCREEN, handleFullscreenChange, false, 0, true); 
			player.addEventListener(VideoEvent.PLAY, handlePlaybackStart, false, 0, true);
			originalSize = {width:player.playerWidth, height:player.playerHeight}; 
			mouseChildren = false;
			mouseEnabled = false;
		} 
		
		private var contextMenuVideoOverlay:Sprite;
		private function handleAddedToStage(e:Event):void
		{
			stage.addEventListener(Event.RESIZE, updateComboPosition, false, 0, true);
			stage.addEventListener(Event.RESIZE, updateLayout, false, 0, true); 
			createContextMenuVideoOverlay();
		}
	
		public function init(config:Params):void
		{ 
			_config = config;
			//Logger.info('\n----------------- DEBUGGING VideoManager ERROR --------------------------\nconfig: '+config)
			timer = new Timer(40);
			timer.addEventListener(TimerEvent.TIMER, handleTimer, false, 0, true);
			
			textField = new SubtitleTextField(config);
			//Logger.info('textField: '+textField)
			textField.width = player.playerWidth; 
			//Logger.info('(player as MoogaloopWrapper): '+(player as MoogaloopWrapper))
			//Logger.info('(player as MoogaloopWrapper).videoManager: '+(player as MoogaloopWrapper).videoManager+', '+( (player as MoogaloopWrapper).videoManager is Sprite ))
			//var videoManager:Sprite = (player as IVideoPlayer).videoManager as Sprite;
			//Logger.info('videoManager: '+videoManager+', textfield: '+textField)
			
			player.video.parent.addChild(textField);
			//Logger.info('text attached');
			if (config.srt) {
				loadSrt(config.srt); 
			} else
				if (config.srtData) {
					setSrtData(config.srtData);
				}
			
			initLocalization(); 
			
			createScreens(); 
		}
		
		public function get config():Params
		{
			return _config;
		}
		
		
		//-------------------------------------------------------------------------------------------
		//
		// GENERAL EVENT HANDLING
		// 
		//-------------------------------------------------------------------------------------------
		
		private function handleFullscreenChange(e:VideoEvent):void
		{	 
			//Logger.info('handleFullscreenChange()')
			currentScale = player.playerWidth / originalSize.width; 
			textField.scale = currentScale;
			updateComboPosition(); 
			
			if (player.jsInterface) {
				var event:JsEvent = new JsEvent(JsEvent.FULLSCREEN_CHANGED);
				event.fullscreen = player.fullscreenMode;
				player.jsInterface.fireEvent(event);
			}
		} 
		
		private var forceTextRefresh:Boolean;
		private function handleTimer(e:Event):void
		{       
			// update text
			var line:SubtitleLine = list.getLineAtTime( player.videoPosition )  
			if (line) { 
				if (line != currentSubtitleLine || forceTextRefresh) {
					subtitleLine = line;
					forceTextRefresh = false;
				}
			}
			else if (currentSubtitleLine) { 
				subtitleLine = null; 
			}
			
			if (_text) {  		
				// update text position		
				updateTextPosition();
			} 
			/* //not so nice
			if (((player as VimeoPlayer).ui as VimeoPlayerUI).playbar.alpha < 1) {
				if (combo) {
					combo.close();
				}
			}*/
			updateComboPosition();
		} 
		
		
		
		//-------------------------------------------------------------------------------------------
		//
		// CONTEXTMENU VIDEO OVERLAY
		// invisible layer above video
		// 
		//-------------------------------------------------------------------------------------------
		/**
		 * Creates an invisible layer above the video.
		 * reason: ContextMenu fails when rightclicked over a video, Flash player bug (currently v10.2)
		 * we put an invisible sprite over the video to avoid the bug
		 */
		private function createContextMenuVideoOverlay():void
		{ 
			var videoManager:Sprite = (player as VimeoPlayer).videoManager as Sprite; 
			contextMenuVideoOverlay = new Sprite(); 
			videoManager.addChild(contextMenuVideoOverlay);
			updateContextMenuVideoOverlay();
		}
		/**
		 * Resizes the invisible layer
		 */
		private function updateContextMenuVideoOverlay(e:Event=null):void
		{
			var g:Graphics = contextMenuVideoOverlay.graphics;
			var w:Number = player.playerWidth;
			var h:Number = player.playerHeight;
			g.clear();
			g.beginFill(0xff0000, 0);
			g.drawRect(0,0,w,h);
			contextMenuVideoOverlay.width = w;
			contextMenuVideoOverlay.height = h;
		}
		
		
		//-------------------------------------------------------------------------------------------
		//
		// SCREENS
		// 
		//-------------------------------------------------------------------------------------------
		public var screens:Array = [];
		public var buttons:Array = [];
		
		public var currentScreen:Screen;
		private function createScreens():void
		{
			var sidedock:Sprite = (player.ui as VimeoPlayerUI).sidedock;
			var vimeoColor:uint = (player as VimeoPlayer).color;
			
			//----------------------------------
			// share screen & button
			//----------------------------------
			
			if (config.shareUrl) {
				
				var btnShare:ShareButton = new ShareButton(player as VimeoPlayer);   
				parent.addChild( btnShare );
				buttons.push(btnShare); 
				btnShare.addEventListener(MouseEvent.CLICK, handleScreenButtonClick, false, 0, true);  
				
				var shareScreen:ShareScreen = new ShareScreen(this);
				shareScreen.button = btnShare; 
				shareScreen.addEventListener(Screen.HIDE, handleHideScreen, false, 0, true);
				parent.addChild(shareScreen);
				screens.push(shareScreen);
				btnShare.screen = shareScreen;
			}
			
			//----------------------------------
			// embed screen & button
			//----------------------------------
			
			if (config.embedUrl) {
				var btnEmbed:EmbedButton = new EmbedButton(player as VimeoPlayer);   
				parent.addChild( btnEmbed );
				buttons.push(btnEmbed); 
				btnEmbed.addEventListener(MouseEvent.CLICK, handleScreenButtonClick, false, 0, true);  
				
				var embedScreen:EmbedScreen = new EmbedScreen(this);
				embedScreen.button = btnEmbed;
				embedScreen.addEventListener(Screen.HIDE, handleHideScreen, false, 0, true);
				parent.addChild(embedScreen);
				screens.push(embedScreen);
				btnEmbed.screen = embedScreen;
			}
			//----------------------------------
			// layout
			//----------------------------------
			updateLayout();				
		}
		
		//-------------------------------------------------------------------------------------------
		//
		// SOCIAL MEDIA BUTTONS
		// 
		//-------------------------------------------------------------------------------------------
		
		private function handlePlaybackStart(e:Event):void
		{ 
			var t:Timer = new Timer(200, 1);
			t.addEventListener(TimerEvent.TIMER_COMPLETE, updateLayout, false, 0, true);
			t.start();
 
			updateComboPosition();
		}
		private function handleScreenButtonClick(e:MouseEvent):void
		{
			// toggle only, if the button's screen is already being shown
			if (currentScreen && currentScreen == e.target.screen) {
				currentScreen.hide();
				currentScreen = null;
				return;
			}
			// otherwise hide any other screen
			if (currentScreen) {
				currentScreen.hide();
			}
			// then show requested screen 
			e.target.screen.show();
			currentScreen = e.target.screen;
			updateLayout(); 
		}
		
		/**
		 * Deals positioning of the buttons.
		 * Initially, the buttons are placed at the top right corner,
		 * but once playbackstarts, the buttons are shifted down below the vimeo buttons in sidedock
		 * and the buttons are actually moved into the sidedock so they can fade out with the rest of the player ui.
		 */
		private function updateLayout(e:Event=null):void
		{  
			 
			// find the top position - dependng on whether the sidedock is visible or not
			var ui:VimeoPlayerUI = (player.ui as VimeoPlayerUI);
			var y:Number = 10; 
			if (ui.sidedock.alpha) { 
				for (var i:int=0; i<ui.sidedock.numChildren; i++) {
					var child:DisplayObject = ui.sidedock.getChildAt(i); 
					if (child.visible && buttons.indexOf(child) == -1 && (!buttons[0] || child.x == (buttons[0] as Sprite).x)) {
						y += child.height+5;
					}
				} 
			} 
			// position the buttons below the top position
			for (i=0; i<buttons.length; i++) {
				var btn:Sprite = buttons[i] as Sprite;
				btn.x = player.playerWidth - btn.width - 10;
				btn.y = y + i*(btn.height+5); 
				if (ui.sidedock.alpha) {
					ui.sidedock.addChild(btn);
				}
			}
			
			// center the screen, if one is being shown
			var s:Screen = this.currentScreen;
			if (s) {
				s.x = (player.playerWidth - s.width) / 2
				s.y = (player.playerHeight - s.height) / 2 - 20;
			} 
			
			updateComboPosition();
			updateContextMenuVideoOverlay();
			
			// bugfix / workaround: context menu listeners get lost after playback. 
			var cm:ContextMenu = (player as VimeoPlayer).moogaloop.contextMenu;
			for each (var item:ContextMenuItem in cm.customItems) { 
				item.removeEventListener(ContextMenuEvent.MENU_ITEM_SELECT, handleContextMenuClick);
				item.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, handleContextMenuClick, false, 0, true); 
			} 
			 
		}
		private function handleHideScreen(e:Event):void
		{
			if (e.target === currentScreen) {
				currentScreen = null;	
			}
		}
		//-------------------------------------------------------------------------------------------
		//
		// SUBTITLE TEXT HANDLING
		// 
		//-------------------------------------------------------------------------------------------
		
		public function set subtitleLine(value:SubtitleLine):void
		{
			currentSubtitleLine = value; 
			setText(value ? value.text : '');
			
			if (player.jsInterface) {
				var event:JsEvent = new JsEvent(JsEvent.SUBTITLE_TEXT);
				event.text = value ? _text : null;
				event.index = value ? list.getLineIndex( value ) : null;
				player.jsInterface.fireEvent(event);
			}
		}
		public function get subtitleLine():SubtitleLine
		{
			return currentSubtitleLine;
		}
		private function setText(value:String):void
		{ 
			_text = value; 
			
			if (value) {
				value = '<span class="subtitle">' + 
					value.replace(/\r\n/g,'<br>')
					.replace(/\r/g,'<br>')
					.replace(/\n/g,'<br>')
					.replace(/<b>/g,'<strong>')
					.replace(/<\/b>/g, '</strong>') 
					+ '</span>'
			} 
			textField.htmlText = StringUtils.removeExtraWhitespace(value); 
			updateTextPosition();
			
			
		} 
		
		public function get text():String
		{
			return _text;
		}
		
		private function updateTextPosition():void
		{  
			var margin:Number = config.margin * currentScale + (config.dynpos ? (player.ui.playbar.alpha ? player.ui.playButton.height > config.margin * currentScale ? player.ui.playButton.height : 0 : 0) : 0);
			textField.y = player.playerHeight - textField.textHeight*currentScale - margin; 
			//	textField.width = player.playerWidth;
			//	textField.x = 0;	
			//Logger.info('playerWidth: '+player.playerWidth+', fs: '+player.fullscreenMode+', pos: '+textField.x+','+textField.y+', size: '+textField.width+', '+textField.height) 
		}
		
		
		//-------------------------------------------------------------------------------------------
		//
		// LOCALIZATION (Multiple languages)
		// 
		//-------------------------------------------------------------------------------------------
		
		public function setLanguage(lang:String):void
		{ 
			var file:String = localization.getFileByLang(lang); 
			loadSrt(file);
			setComboLanguage(lang);
		}
		public function setComboLanguage(lang:String):void
		{			
			if (!combo) {
				return;
			}
			for (var i:int=0,t:int=combo.dataProvider.length; i<t; i++) {
				var item:Object = combo.dataProvider.getItemAt(i);
				if (item.lang == lang) {
					combo.selectedIndex = i;
				}
			}
			updateComboPosition();
		}
		
		public var currentLanguage:Object;
		private var localizationUrl:String;
		private function initLocalization():void
		{	 
			localizationUrl = BrowserUtil.hashParam('vp-list') || config.localization;
			if (localizationUrl) { 
				localization = new LocalizationXML();
				localization.noCaching = true;
				localization.addEventListener(XMLProxy.COMPLETE, handleLocalizationXmlComplete, false, 0, true);
				localization.addEventListener(XMLProxy.ERROR, handleLocalizationXmlError, false, 0, true); 
				localization.loadXML(localizationUrl);
				
				if (player.jsInterface) {
					var event:JsEvent = new JsEvent(JsEvent.LOAD_LOCALIZATION);
					event.localizationUrl = localizationUrl;
					player.jsInterface.fireEvent(event);
				}
			}	
		}
		
		private function handleLocalizationXmlComplete(e:Event):void
		{    
			createCombo();
			updateComboPosition(); 
			
			if (config.lang) {
				setLanguage(config.lang);
			} else if (localization.defaultLang) {
				setLanguage(localization.defaultLang);
			}
			
			localization.removeEventListener(XMLProxy.COMPLETE, handleLocalizationXmlComplete);
			localization.removeEventListener(XMLProxy.ERROR, handleLocalizationXmlError); 
			
			createContextMenuItems();
			
			if (player.jsInterface) {
				var event:JsEvent = new JsEvent(JsEvent.LOCALIZATION_LOADED);
				event.localizationUrl = config.localization;
				player.jsInterface.fireEvent(event);
			}
		}
		private function handleLocalizationXmlError(e:Event):void
		{
			throw new Error('Localization url '+localizationUrl+' not loaded!');
			localization.removeEventListener(XMLProxy.COMPLETE, handleLocalizationXmlComplete);
			localization.removeEventListener(XMLProxy.ERROR, handleLocalizationXmlError); 
			
			if (player.jsInterface) {
				var event:JsEvent = new JsEvent(JsEvent.LOCALIZATION_ERROR);
				event.localizationUrl = config.localization;
				player.jsInterface.fireEvent(event);
			}
		} 
		
		private var langTooltip:Sprite;
		
		private function handleComboTooltipMouseMove(e:MouseEvent):void
		{
			//Logger.info('targets '+e.target.y);
			if (langTooltip) {
				langTooltip.x = combo.x + combo.width + 7;
				langTooltip.y = combo.y - (combo.height*(combo.dataProvider.length)) +  e.target.y;
			}
		} 
		
		private function removeComboTooltip(e:Event=null):void
		{
			try {
				langTooltip.parent.removeChild(langTooltip);
				stage.removeEventListener(MouseEvent.MOUSE_MOVE, handleComboTooltipMouseMove);
				langTooltip = null;
			}
			catch (err:Error) {
				
			}
		}
		private function handleComboItemRollOver(e:ListEvent):void
		{
			var d:String = combo.dataProvider.getItemAt(Number(e.rowIndex.toString())).description;
			if(d) {
			 
				removeComboTooltip();
				
				langTooltip = new Sprite();
				
				var pad:Number = 3;
				var extraW:Number = 2;
				var extraH:Number = 3;
				var triHeight:Number = 7;
				var triWidth:Number = 7;
				var tf:TextField = new TextField();
				tf.autoSize = TextFieldAutoSize.LEFT;
				tf.embedFonts = true;
				var tformat:TextFormat = new TextFormat();
				tformat.font = new _UNI_05_53().fontName;
				tformat.color = 0xffffff;
				tformat.size = 8;
				tf.defaultTextFormat = tformat;
				tf.text = d;
				tf.x = pad;
				tf.y = pad;
				 
				var w:Number = tf.textWidth+pad*2+extraW
				var h:Number = tf.textHeight+pad*2+extraH;
				var g:Graphics = langTooltip.graphics;
				g.clear(); 
				g.beginFill((player as VimeoPlayer).color, 0.95);
				g.drawRoundRect(0,0,w,h,10,10);
				g.moveTo(0, h/2 - triHeight/2);
				g.lineTo(-triWidth, h/2);
				g.lineTo(0, h/2 + triHeight/2);
				g.endFill();
				
				langTooltip.alpha = 0;
				langTooltip.addChild(tf);
				langTooltip.x = e.target.x + e.target.width + triWidth;
				langTooltip.y = parent.mouseY;
				
				
				var t:Timer = new Timer(1, 1);
				t.addEventListener(TimerEvent.TIMER_COMPLETE, function(e:TimerEvent):void {
					if (langTooltip) {
						TweenLite.to(langTooltip, 0.1, {alpha: 1});	
					}
				}, false, 0, true);
				t.start();
				
				langTooltip.filters = [new DropShadowFilter(4,45,0,0.5)];
				parent.addChild(langTooltip); 
				stage.addEventListener(MouseEvent.MOUSE_MOVE, handleComboTooltipMouseMove, false, 0, true);
			}
			else {
				removeComboTooltip();
			}
			
			

			
		}
 
		private function handleComboItemRollOut(e:ListEvent):void
		{
			if (langTooltip && langTooltip.parent) { 
				stage.removeEventListener(MouseEvent.MOUSE_MOVE, handleComboTooltipMouseMove);
				langTooltip.parent.removeChild(langTooltip)
				langTooltip = null;
			}
		}
		
		private var menuItems:Array;
		private function createContextMenuItems():void
		{ 
			var cmItems:Array = [];
			menuItems = [];
			var cm:ContextMenu = (player as VimeoPlayer).moogaloop.contextMenu; 
			for each (var lang:String in localization.languages) { 
				var obj:Object = {
					caption: 'Download subtitles: '+localization.getTitleByLang(lang),
					url: localization.getFileByLang(lang)
				} 
				if (localization.getDescriptionByLang(lang)) {obj.caption += ' - '+localization.getDescriptionByLang(lang);}
				menuItems.push(obj);
				
				var cmi:ContextMenuItem = new ContextMenuItem(obj.caption);
				cmi.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, handleContextMenuClick, false, 0, true);
				cmItems.push(cmi);
			}
			cmItems.reverse();
			for each (var item:ContextMenuItem in cmItems) {
				cm.customItems.splice(1, 0, item);
			}
			/*for each (var item:Object in menuItems) { 
			var cmi:ContextMenuItem = new ContextMenuItem(item.caption);				
			cmi.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, handleContextMenuClick);
			cm.customItems.splice(0,0,cmi)
			} 
			*/
			//(player as VimeoPlayer).moogaloop.contextMenu = cm;
		}
		private function handleContextMenuClick(e:ContextMenuEvent):void
		{
			//Logger.info('handleContextMenuClick');
			for each (var item:Object in menuItems) {
				if (item.caption == e.target.caption) {
					var req:URLRequest = new URLRequest(item.url);
					//Logger.info('download srt', item.url);
					navigateToURL(req, '_blank');
				}
			}
		}
		private function createCombo():void
		{
			combo = new ComboBox();  
			combo.addEventListener(Event.CHANGE, handleComboChange, false, 0, true); 
			combo.width = player.ui.playButton.width;
			combo.height = 20; 
			combo.setStyle('textPadding',2); 
			
			combo.addEventListener(ListEvent.ITEM_ROLL_OVER, handleComboItemRollOver, false, 0, true);
			combo.addEventListener(ListEvent.ITEM_ROLL_OUT, handleComboItemRollOut, false, 0, true);
			combo.addEventListener(Event.CLOSE, removeComboTooltip, false, 0, true);
			var format:TextFormat = new TextFormat()
			format.color = 0xFFFFFF;
			format.bold = false;
			format.font = new _UNI_05_53().fontName; 
			format.size = 8;
			
			combo.dropdown.setRendererStyle("embedFonts",true);
			combo.dropdown.setRendererStyle("textFormat",format);
			combo.dropdown.setRendererStyle("antiAliasType",AntiAliasType.NORMAL);
			
			combo.textField.setStyle("embedFonts",true); 
			combo.textField.setStyle("textFormat",format);
			combo.textField.setStyle("antiAliasType",AntiAliasType.NORMAL);
			combo.textField.textField.autoSize = TextFieldAutoSize.LEFT;
			var need_tooltip:Array = [];
			var dp:Array = [{label:'no subtitles',lang:null}]; 
			for each (var lang:String in localization.languages) {
				var name:String = localization.getTitleByLang(lang);
				var item:Object = {
					'srtFile': localization.getFileByLang(lang),
					'lang': lang,			
					'name': name,
					'label': name,
					'fontName': localization.getFontNameByLang(lang),
					'fontFile': localization.getFontFileByLang(lang),
					'fontSize': localization.getFontSizeByLang(lang),
					'description': localization.getDescriptionByLang(lang)
				}
				dp.push(item); 
				if (localization.getDescriptionByLang(lang)) {
					need_tooltip.push( name );
				}
			}
			combo.rowCount = dp.length;
			combo.dataProvider = new DataProvider(dp);
			player.ui.playbar.addChild(combo);
			 
			if (player.jsInterface) {
				var event:JsEvent = new JsEvent(JsEvent.LANGUAGE_MENU_CREATED); 
				player.jsInterface.fireEvent(event);
			} 
			//Logger.info('config.menu: '+config.menu+', _hideCombo: '+_hideCombo)
			updateComboPosition();
			
		}  
		public function disableCombo():void
		{
			if (!combo) {
				return;
			}
			combo.mouseEnabled = false;
			combo.mouseChildren = false;
			combo.alpha = 0.7;
			removeComboTooltip();
			updateComboPosition();
		}
		public function enableCombo():void
		{
			if (!combo) {
				return;
			}
			combo.mouseEnabled = true;
			combo.mouseChildren = true;
			combo.alpha = 1;
			updateComboPosition();
		}
		
		
		public function set hideCombo(value:Boolean):void
		{
			_hideCombo = value;
			if (combo) {
				combo.visible = false;
				removeComboTooltip();
			}
		}
		public function get hideCombo():Boolean
		{
			return _hideCombo;
		}
		
		private var nextFontName:String;
		private var nextFontSize:Number;
		private var spinner:CircleSlicePreloader;
		
		private function handleComboChange(e:Event):void
		{   
			var lang:String = combo.selectedItem.lang;
			var langName:String = combo.selectedItem.title;
			var srt:String = localization.getFileByLang(lang);
			
			if (player.jsInterface) {
				var event:JsEvent = new JsEvent(JsEvent.LANGUAGE_CHANGED);
				event.lang = lang;
				event.langName = langName;
				player.jsInterface.fireEvent(event);
			}
			
			loadSrt(srt);   
		} 
		private function updateComboPosition(e:Event=null):void
		{
			if (combo) { 
				combo.x = player.ui.playButton.x;
				combo.y = player.playerHeight - combo.height - player.ui.playButton.height - 20;
				if (!config.menu || _hideCombo) {
					combo.visible = false;
					combo.y = -1000;
				}
			}
		}
		
		//-------------------------------------------------------------------------------------------
		//
		// LOADING A FONT SWF
		// 
		//-------------------------------------------------------------------------------------------
		
		public function loadFont(url:String):void
		{
			textField.font = url;
			
			/*
			var loader:FontLoader = new FontLoader();
			addChild(loader)
			loader.loadFont( url );
			*/
		}
		 
		
		
		//-------------------------------------------------------------------------------------------
		//
		// LOADING THE SRT FILE
		// 
		//-------------------------------------------------------------------------------------------
		
		private function updateFont():void
		{			
			trace('update font >>')
			var lang:String = combo.selectedItem.lang;
			var langName:String = combo.selectedItem.title;
			var srt:String = localization.getFileByLang(lang);			
			var fontFile:String = combo.selectedItem.fontFile;	 
			if (fontFile) { 
				spinner = new CircleSlicePreloader(12,2,0x333333);
				spinner.x = combo.x + combo.width + 12;
				spinner.y = combo.y + 10;
				addChild(spinner)
				FontManager.instance.addEventListener(Event.COMPLETE, handleFontLoaded);
				FontManager.instance.loadFont(fontFile);
				nextFontName = combo.selectedItem.fontName;	
				nextFontSize = combo.selectedItem.fontSize || SubtitleTextField.defaultFontSize;	
			}			
			else { 
				textField.font = SubtitleTextField.defaultFontName
				textField.fontSize = SubtitleTextField.defaultFontSize;
			} 
		}
		
		private function handleFontLoaded(e:Event):void {
			removeChild(spinner);
			spinner = null;
			textField.font = nextFontName;
			textField.fontSize = nextFontSize;
			trace('font set to '+nextFontName+' ('+nextFontSize+')')
		}
		
		public var currentSrtUrl:String;
		public function loadSrt(file:String):void
		{ 
			if (!file) {
				timer.stop();
				subtitleLine = null;
				list = null;
				return;
			}
			
			
			var urlLoader:URLLoader = new URLLoader( new URLRequest( file ) );
			urlLoader.addEventListener(Event.COMPLETE, handleSrtLoaded, false, 0, true);
			urlLoader.addEventListener(IOErrorEvent.IO_ERROR, handleSrtError, false, 0, true);
			urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, handleSrtError, false, 0, true);
			currentSrtUrl = file;
			
			var i:int=0;
			while (i<combo.dataProvider.length) {
				//Logger.info('srtFile', i, combo.dataProvider.getItemAt(i).srtFile, file)
				var cb_item:Object = combo.dataProvider.getItemAt(i); 
				if (cb_item && cb_item.srtFile == file) {
					combo.selectedIndex = i;
				}
				i++;
			}
			
			if (player.jsInterface) {
				var event:JsEvent = new JsEvent(JsEvent.LOAD_SRT);
				event.srtUrl = currentSrtUrl;
				player.jsInterface.fireEvent(event);
			}
		} 
		private function handleSrtError(e:Event):void
		{ 
			if (player.jsInterface) {
				var event:JsEvent = new JsEvent(JsEvent.SRT_ERROR);
				player.jsInterface.fireEvent(event);
			}
			throw new Error('Failed loading subtitles: ' + e);
		}
		private function handleSrtLoaded(e:Event):void
		{ 
			var srt_data:String = e.target.data.toString();
			setSrtData(srt_data);
			
			updateFont();
			
			trace('srt loaded: '+currentSrtUrl)
		}
		public function setSrtData(value:String):void
		{
			
			var lines:Array = SubtitleParser.parseSRT( value );
			trace('parsed '+lines.length+' subtitle lines');
			list = new SubtitlesList(lines, currentSrtUrl);			
			timer.start(); 			
			dispatchEvent( new Event( Event.COMPLETE ) ); 
			
			if (player.jsInterface) {
				var event:JsEvent = new JsEvent(JsEvent.SRT_LOADED);
				event.srtUrl = currentSrtUrl;
				player.jsInterface.fireEvent(event);
			}
			
			if (combo) {
				setComboLanguage( localization.getLangByFile( currentSrtUrl) );
			}
		}
		
		public function changeLine(oldLine:SubtitleLine, newLine:SubtitleLine):void
		{ 
			for each (var line:SubtitleLine in list.list) {
				if (SubtitleLine.match(oldLine, line)) { 
					//Logger.info('found match!', line, newLine)
					//Logger.info('------------------------------------------------------------'); 
					//Logger.info('\nold line: ',oldLine);
					//Logger.info('\nnew line: ',newLine);  
					line.apply(newLine);
					forceTextRefresh = true;
				}
			} 
		}
		
		public function parseSrt(file:String=null, jsInterfaceHandler:String=null):String
		{
			var result:String = "";
			if (!file) {
				if (list) {
					result = list.toJson();
				}
			}
			else { 
				var loaded:Function = function(e:Event):void {
					var lines:Array = SubtitleParser.parseSRT( e.target.data.toString() );  
					if (jsInterfaceHandler && ExternalInterface.available) { 
						var _list:SubtitlesList = new SubtitlesList(lines, file); 
						var _result:String = _list.toJson(); 
						ExternalInterface.call(jsInterfaceHandler, _result);
					}
				}
				var error:Function = function(e:Event):void {
					throw new Error('could not load file '+file);
				} 
				var urlLoader:URLLoader = new URLLoader( new URLRequest( file ) );
				urlLoader.addEventListener(Event.COMPLETE, loaded, false, 0, true);
				urlLoader.addEventListener(IOErrorEvent.IO_ERROR, error, false, 0, true);
				urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, error, false, 0, true); 
			}
			return result;
		}
		
		public function destroy():void
		{ 
			if (combo) {
				combo.removeEventListener(Event.CHANGE, handleComboChange); 
			}
			player.removeEventListener(VideoEvent.FULLSCREEN, handleFullscreenChange); 
			timer.removeEventListener(TimerEvent.TIMER, handleTimer);
			timer.stop();
		}
	}
}