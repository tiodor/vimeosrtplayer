package org.mindpirates.websubs.ui.vimeo.sidedock
{
	import de.derhess.video.vimeo.VimeoPlayer;
	
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import org.mindpirates.video.interfaces.IVimeoPlayer;
	import org.mindpirates.websubs.ui.Screen;
	import org.osflash.thunderbolt.Logger;
	
	public class SidedockButton extends Sprite
	{ 
		/**
		 * The associated screen instance
		 */
		public var screen:Screen;
		
		//-----------------------------------------------------------------
		//
		// CHILD ELEMENTS
		//
		//-----------------------------------------------------------------
		
		/**
		 * Background sprite. Rounded rectangle is drawn in this.
		 */
		public var background:Sprite;
		
		/**
		 * The textfield. It's text can be set with the <code>text</code> setter.
		 */
		public var field:TextField;
		
		/**
		 * A sprite that contains icons or graphics
		 */
		public var artwork:Sprite;
		
		
		//-----------------------------------------------------------------
		//
		// PUBLIC VARS THAT AFFECT THE VISUALITY
		//
		//-----------------------------------------------------------------
		
		/**
		 * Radius of the rounded corners
		 */
		public var cornerRadius:Number = 10;
		
		/**
		 * Background color for the normal button state
		 */
		public var bgColorNormal:Number = 0x172322;
		
		/**
		 * Background color for the rollover button state
		 */
		public var bgColorOver:Number = 0xffffff;
		
		/**
		 * Foreground color for the normal button state. Affects text, and if <code>tintArtwork</code> is set to TRUE, the artwork
		 */
		public var colorNormal:Number = 0xffffff; 
		
		/**
		 * Foreground color for the rollover button state. Affects text, and if <code>tintArtwork</code> is set to TRUE, the artwork
		 */
		public var colorOver:Number = 0x172322;
				
		/**
		 * Background alpha for the normal button state
		 */
		public var bgAlphaNormal:Number = 1;
		
		/**
		 * Background alpha for the rollover button state
		 */
		public var bgAlphaOver:Number = 1;
		
		/**
		 * Whether or not to apply the foreground color to the artwork.
		 * @see colorNormal
		 * @see colorOver
		 */
		public var tintArtwork:Boolean = false;
		
		/**
		 * Distance around artwork and text. This affects top and bottom distance only, as both text and artwork are horizontally centered, ignoring this value.
		 */
		public var padding:Number = 5;
		
		/**
		 * Whether or not this button toggles its clicked state
		 */
		public var toggles:Boolean = false;
		
		//-----------------------------------------------------------------
		//
		// PRIVATE VARS
		//
		//-----------------------------------------------------------------
		
		/**
		 * @private
		 * Holds the current background color value, which can be either bgColorNormal or bgColorOver
		 */
		private var _bgColor:Number = bgColorNormal;
		
		/**
		 * @private
		 * Holds the current background alpha value, which can be either bgAlphaNormal or bgAlphaOver
		 */
		private var _bgAlpha:Number = bgAlphaNormal;
		
		/**
		 * @private
		 * Holds the current foreground color value, which can be either colorNormal or colorOver
		 */
		private var _color:Number = colorNormal;
		
		/**
		 * @private
		 * Holds the clicked status of the button
		 */
		private var isClicked:Boolean = false;
		
		/**
		 * @private
		 * Holds the current background width
		 * @see width
		 */
		private var _width:Number;
		
		/**
		 * @private
		 * Holds the current background height
		 * @see height
		 */
		private var _height:Number;
		
		
		/**
		 * @private
		 * Holds the current text value
		 * @see text
		 */
		private var _text:String;
		
		
		//-----------------------------------------------------------------
		//
		// CONSTRUCTOR
		//
		//-----------------------------------------------------------------
		
		public function SidedockButton(player:VimeoPlayer)
		{
			super();
			
			_width = 45;
			_height = 33;
			
			background = new Sprite();
			addChild(background);
			
			field = new TextField();
			field.antiAliasType = AntiAliasType.ADVANCED;
			field.multiline = false;
			field.embedFonts = true;
			field.defaultTextFormat = new TextFormat(new _DejaVuBold().fontName, 8, colorNormal, true, null, null, null, null, TextFormatAlign.CENTER, 0, 0, 0, 0);
			addChild(field);
			 
			artwork = new Sprite();
			addChild(artwork);
			
			useHandCursor = true;
			buttonMode = true;
			mouseChildren = false;
			 
			colorOver = 0xffffff;
			bgColorOver = player.color;
			
			addEventListener(MouseEvent.CLICK, handleClick, false, 0, true);
			addEventListener(MouseEvent.ROLL_OVER, handleRollOver, false, 0, true);
			addEventListener(MouseEvent.ROLL_OUT, handleRollOut, false, 0, true);
			addEventListener(Event.ADDED_TO_STAGE, update, false, 0, true);
			update();
		}
		
		//-----------------------------------------------------------------
		//
		// EVENT HANDLERS
		//
		//-----------------------------------------------------------------
		
		/**
		 * @private
		 * Handles the click event. Sets display vars and calls <code>update()</code>
		 */ 
		private function handleClick(e:MouseEvent=null):void
		{
			if (toggles) {
				isClicked = !isClicked;
			}
			update();
		}
		
		/**
		 * @private
		 * Handles the rollover event. Sets display vars and calls <code>update()</code>
		 */ 
		private function handleRollOver(e:MouseEvent=null):void
		{
			if (toggles && isClicked) {
				return;
			}
			_bgColor = bgColorOver;
			_bgAlpha = bgAlphaOver;
			_color = colorOver;			
			update();	
		}
		
		/**
		 * @private
		 * Handles the rollout event. Sets display vars and calls <code>update()</code>
		 */
		private function handleRollOut(e:MouseEvent=null):void
		{
			if (toggles && isClicked) {
				return;
			}
			_bgColor = bgColorNormal;
			_bgAlpha = bgAlphaNormal;
			_color = colorNormal;			
			update();
		}
		
		//-----------------------------------------------------------------
		//
		// PUBLIC GETTERS / SETTERS
		//
		//-----------------------------------------------------------------
		
		/**
		 * Sets the text value.
		 */
		public function set text(value:String):void
		{
			_text = value;
			update();
		}
		
		/**
		 * Gets the text value.
		 */
		public function get text():String
		{
			return _text;
		}
		 
		/**
		 * Sets the width.
		 */
		override public function set width(value:Number):void
		{
			_width = value;
			update();
		}
		
		/**
		 * Gets the width.
		 */
		override public function get width():Number
		{
			return _width;
		}
		
		/**
		 * Sets the height.
		 */
		override public function set height(value:Number):void
		{
			_height = value;
			update();
		}
		
		/**
		 * Gets the height.
		 */
		override public function get height():Number
		{
			return _height;
		}
		
		public function reset(e:Event=null):void
		{
			isClicked = false;
			if (stage && hitTestPoint(stage.mouseX, stage.mouseY, true)) {
				handleRollOver();
			}
			else {
				handleRollOut();
			}
		}
		
		/**
		 * renders the whole button.
		 */
		public function update(e:Event=null):void
		{			 
			if (_text) {
				field.text = _text;
				field.width = _width;
				field.height = field.textHeight;
				field.x = 0;
				field.y = _height - field.textHeight - padding;
				field.visible = true;
			}
			else {
				field.visible = false;
			}
			
			var f:TextFormat = field.defaultTextFormat;
			f.color = _color;
			field.defaultTextFormat = f;
			field.setTextFormat(f);
			
			artwork.x = (_width - artwork.width) / 2;
			artwork.y = padding;
			
			var g:Graphics = background.graphics;
			g.clear(); 
			g.beginFill(_bgColor);
			g.drawRoundRect(0, 0, _width, _height, cornerRadius);
			background.alpha = _bgAlpha;
		}
	}
}