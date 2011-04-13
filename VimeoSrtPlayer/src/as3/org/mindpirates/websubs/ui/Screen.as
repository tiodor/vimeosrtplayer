package org.mindpirates.websubs.ui
{
	import com.greensock.TweenLite;
	
	import de.derhess.video.vimeo.VimeoPlayer;
	
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.text.TextField;
	import flash.utils.Timer;
	
	import org.mindpirates.websubs.SubtitlesLayer;
	import org.mindpirates.websubs.ui.vimeo.sidedock.SidedockButton;
	import org.osflash.thunderbolt.Logger;
	
	[Event(name="show", type="flash.events.Event")]
	[Event(name="hide", type="flash.events.Event")]
	public class Screen extends Sprite implements IScreen
	{
		public static const SHOW:String = 'show';
		public static const HIDE:String = 'hide';
		public const TWEEN_DURATION:Number = 0.2;
		public var type:String; 
		public var contents:Sprite;
		public var bg:Sprite;
		public var margin:Number = 10;
		public var cornerRadius:Number = 20;
		public var subtitles:SubtitlesLayer;
		public var titleField:TextField;
		public var button:SidedockButton;
		public function Screen(subtitlesLayer:SubtitlesLayer)
		{ 			
			subtitles = subtitlesLayer;
			visible = false;
			alpha = 0;
			
			bg = new Sprite();
			bg.addEventListener(MouseEvent.MOUSE_DOWN, handleBgMouseDown, false, 0, true);
			bg.addEventListener(MouseEvent.MOUSE_UP, handleBgMouseUp, false, 0, true);
			addChild(bg);
			
			contents = new Sprite();
			addChild(contents);  
		}
		
		public function show(e:Event=null):void
		{ 
			visible = true; 
			TweenLite.to(this,TWEEN_DURATION,{alpha:1});
			dispatchEvent( new Event( SHOW ) );
		}
		
		public function hide(e:Event=null):void
		{
			if (button) {
				button.reset();
			} 
			var self:Screen = this;
			TweenLite.to(this, TWEEN_DURATION, {alpha:0, onComplete:function():void {
				self.visible = false; 
				self.dispatchEvent( new Event( HIDE ) );
			}}); 
		}
		
		public function redraw(e:Event=null):void
		{ 
			var g:Graphics = bg.graphics;
			g.beginFill(0x000000, 0.8);
			g.drawRoundRect(0, 0, contents.width+2*margin, contents.height+2*margin, cornerRadius, cornerRadius);
			g.endFill();
			
			contents.x = margin;
			contents.y = margin;
			if (titleField) {
				titleField.x =((contents.width)-titleField.textWidth)/2;
				titleField.width = titleField.textWidth;
			}
		}
		
		private function handleBgMouseDown(e:MouseEvent):void
		{
			startDrag();
		}
		private function handleBgMouseUp(e:MouseEvent):void
		{
			stopDrag();	
		}
		
	}
}