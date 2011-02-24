package de.loopmode.graphics
{
	import flash.display.Sprite;
	
	import org.osflash.thunderbolt.Logger;
	
	public class Rect extends Sprite
	{
		
		private var _width:Number;
		private var _height:Number;
		private var _radius:Number;
		private var _color:uint;
		private var _alpha:Number;
		
		public function Rect(w:Number, h:Number, clr:uint=0x222222, a:Number=1, rad:Number=10)
		{
			super();
			_width = w;
			_height = h;
			_color = clr;
			_alpha = a;
			_radius = rad;
			draw();
		}
		 
		
		//----------------------------------------------------------- 
		//
		// size
		//
		//-----------------------------------------------------------
		
		override public function set width(value:Number):void
		{
			_width = value; 
			draw();
		} 
		
		override public function get width():Number
		{
			return _width; 
		} 
		
		override public function set height(value:Number):void
		{
			_height = value; 
			draw();
		} 
		
		override public function get height():Number
		{
			return _height; 
		} 
		
		//----------------------------------------------------------- 
		//
		// alpha
		//
		//-----------------------------------------------------------
		
		public function set fillAlpha(value:Number):void
		{
			_alpha = value;
			draw();
		}
		public function get fillAlpha():Number
		{
			return _alpha;
		}
		
		//----------------------------------------------------------- 
		//
		// color
		//
		//-----------------------------------------------------------
		
		public function set color(value:uint):void
		{
			_color = value;
			draw();
		}
		public function get color():uint
		{
			return _color;
		}
		
		
		//----------------------------------------------------------- 
		//
		// radius
		//
		//-----------------------------------------------------------
		
		public function set radius(value:Number):void
		{
			_radius = value;
			draw();
		}
		public function get radius():Number
		{
			return _radius;
		}
		
		//----------------------------------------------------------- 
		//
		// draw
		//
		//-----------------------------------------------------------
		
		public function draw():void
		{   
			graphics.clear();
			graphics.beginFill(_color,_alpha);
			graphics.drawRoundRect(0,0,_width,_height,radius,radius);
			graphics.endFill();
		}
	}
}