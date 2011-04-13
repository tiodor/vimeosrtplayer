package org.mindpirates.websubs.ui
{
	import com.greensock.TimelineLite;
	import com.greensock.TweenLite;
	
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.filters.DropShadowFilter;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.utils.Timer;
	
	import org.osflash.thunderbolt.Logger;
	
	public class PlayerTooltip extends Sprite
	{
		private var _target:Sprite;
		private var _text:String;
		private var _options:TooltipOptions;
		private var _field:TextField;
		public function PlayerTooltip(target:Sprite, text:String=null, o:TooltipOptions=null)
		{
			super();
			_target = target;
			_text = text;  
			_options = o || new TooltipOptions();
			_target.addEventListener(MouseEvent.ROLL_OVER, show, false, 0, true);
			_target.addEventListener(MouseEvent.ROLL_OUT, hide, false, 0, true);
			
			_field = new TextField();
			_field.embedFonts = true;
			_field.autoSize = TextFieldAutoSize.LEFT;
			var format:TextFormat = new TextFormat();
			format.font = new _DejaVu().fontName;
			format.color = 0xFFFFFF;
			format.size = 10;
			_field.defaultTextFormat = format;
			addChild(_field);
			
			if (_target.parent) {
				_target.parent.addChild(this);	
			}
			else {
				var self:PlayerTooltip = this;
				var add:Function = function(e:Event):void
				{
					target.parent.addChild(self);
					target.removeEventListener(Event.ADDED_TO_STAGE, add);
				}
				_target.addEventListener(Event.ADDED_TO_STAGE, add, false, 0, true);
			}
			
			alpha = 0;
			mouseEnabled = false;
			mouseChildren = false;
			
			update();
		}
		private var showTimer:Timer;
		private function show(e:Event=null):void
		{
			if (showTimer) {
				showTimer.stop();
				showTimer.reset();
			}
			
			showTimer = new Timer(options.delay, 1);
			showTimer.addEventListener(TimerEvent.TIMER_COMPLETE, fadeIn, false, 0, true);
			showTimer.start();
			
			_target.addEventListener(MouseEvent.MOUSE_MOVE, update, false, 0, true);
		}
		private function fadeIn(e:Event=null):void
		{
			TweenLite.to(this, 0.3, {alpha:1});
		}
		private function fadeOut(e:Event=null):void
		{
			TweenLite.to(this, 0.3, {alpha:1});
		}
		private function hide(e:Event=null):void
		{
			if (showTimer) {
				showTimer.stop();
				showTimer.reset();
			}
			_target.removeEventListener(MouseEvent.MOUSE_MOVE, update);
			TweenLite.to(this, 0.3, {alpha:0});
		}
		public function get target():Sprite
		{
			return _target;
		}
		public function get text():String
		{
			return _text;
		}
		public function set text(value:String):void
		{
			_text = value;
			update();
		}
		public function set options(value:TooltipOptions):void
		{
			_options = value;
			update();
		}
		public function get options():TooltipOptions
		{
			return _options;
		}
		public function update(e:Event=null):void
		{
			if (!stage) {
				return;
			}
			
			var _x:Number = stage.mouseX;
			var _y:Number = stage.mouseY;
			var _w:Number = _field.textWidth+options.padding*2+options.extraWidth;
			var _h:Number = _field.textHeight+options.padding*2+options.extraHeight;
			
			if (_x+_w > options.player.playerWidth){
				_x = stage.mouseX - _w; 
			}
			if (_y+_h > options.player.playerHeight){
				_y = stage.mouseY - _h; 
			}
			
			_field.text = _text;
			_field.x = options.padding;
			_field.y = options.padding;
			
			var g:Graphics = graphics;
			g.clear(); 
			g.beginFill(options.bgColor, options.bgAlpha);
			g.drawRoundRect(0, 0, _w, _h, options.cornerRadius);
			
			if (options.dropShadow) {
				filters = [new DropShadowFilter(4,45,0,0.5,4,4,0.8,1)];
			}
			else {
				filters = [];
			}
			x = _x;
			y = _y;
		}
	}
}