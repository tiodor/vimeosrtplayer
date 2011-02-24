package org.mindpirates.ui
{
	import com.greensock.TweenMax;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	
	/**
	 * Base class for button sprites with two elements.
	 * first child element is normal state
	 * second child element is hover state
	 * Fades the hover state element in on rollover, fades it out on rollout.
	 */ 
	public class HoverButton extends Sprite
	{ 
		public var tweenDuration:Number = 0.3;
		private var _selected:Boolean = false;
		public function HoverButton()
		{
			super(); 
			buttonMode = true;
			useHandCursor = true; 
			mouseChildren = false;
			addEventListener(MouseEvent.ROLL_OVER, handleMouseOver, false, 0, true);
			addEventListener(MouseEvent.ROLL_OUT, handleMouseOut, false, 0, true);
			getChildAt(1).alpha = 0;
		}
		
		private function handleMouseOver(e:MouseEvent):void
		{  
			if (_selected) 
			{
				return;
			}
			if (tweenDuration == 0) 
			{
				getChildAt(1).alpha = 1;
			}
			else {
				TweenMax.to(getChildAt(1), tweenDuration, {alpha:1});
			}
			
		}
		
		private function handleMouseOut(e:MouseEvent):void
		{						
			if (_selected) 
			{
				return;
			}
			if (tweenDuration == 0) 
			{
				getChildAt(1).alpha = 0;				
			}
			else {
				TweenMax.to(getChildAt(1), tweenDuration, {alpha:0});
			}
		}
		
		public function destroy():void {
			removeEventListener(MouseEvent.ROLL_OVER, handleMouseOver);
			removeEventListener(MouseEvent.ROLL_OUT, handleMouseOut);
		}
		
		public function set selected(value:Boolean):void
		{
			if (value)
			{
				handleMouseOver(null);
				_selected = value;
			}
			else 
			{
				_selected = value;
				handleMouseOut(null);
			}
		}
		public function get selected():Boolean
		{
			return _selected;
		}
	}
}