package org.mindpirates.ui
{
	import de.derhess.video.vimeo.VimeoPlayer;
	import de.loopmode.graphics.Rect;
	
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	
	import org.osflash.thunderbolt.Logger;
	
	public class RoundedButton extends HoverButton
	{
		 
		public var upSprite:Rect;
		public var overSprite:Rect; 
		
		public function RoundedButton(w:Number, h:Number)
		{    
			upSprite = new Rect(w,h,0x333333);
			addChild(upSprite);
			
			overSprite = new Rect(w,h,0x444444);
			addChild(overSprite);
			 
			super();
			   
		}   
		
		override public function set width(value:Number):void
		{
			upSprite.width = value;	
			overSprite.width = value; 
		}
		
		override public function set height(value:Number):void
		{
			upSprite.height = value;	
			overSprite.height = value; 
		}
		 
		 
	}
}