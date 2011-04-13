package org.mindpirates.websubs.ui
{
	import flash.display.InteractiveObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	
	import org.osflash.thunderbolt.Logger;

	public class ButtonDecorator
	{
		private var target:Sprite;
		private var rollOverColor:Number;
		private var _toggles:Boolean;
		private var _active:Boolean = false;
		public function ButtonDecorator(btn:Sprite, roColor:uint, toggles:Boolean=false)
		{  
			target = btn;
			target.useHandCursor = true;
			target.buttonMode = true;
			target.mouseChildren = false;
			rollOverColor = roColor;
			target.addEventListener(MouseEvent.ROLL_OVER, handleRollOver, false, 0, true);
			target.addEventListener(MouseEvent.ROLL_OUT, handleRollOut, false, 0, true);
			target.addEventListener(MouseEvent.CLICK, handleClick, false, 0, true); 
			_toggles = toggles;
		}
		private function handleClick(e:MouseEvent):void
		{ 
			if (_toggles) {
				_active = !_active;
				if (_active) {
					handleRollOver(e, true);
				}
				else {
					handleRollOut(e, true);
				}
			}
		}
		private function handleRollOver(e:MouseEvent, manual:Boolean=false):void
		{ 
			if (!manual && _toggles && _active) {
				return;
			}
			var transform:ColorTransform = new ColorTransform();
			transform.color = rollOverColor;
			if (target.numChildren > 0) {
				target.getChildAt(0).transform.colorTransform = transform;
			}
			else {
				target.transform.colorTransform = transform;
			}
		}
		private function handleRollOut(e:MouseEvent, manual:Boolean=false):void
		{
			if (!manual && _toggles && _active) {
				return;
			} 
			if (target.numChildren > 0) {
				target.getChildAt(0).transform.colorTransform = new ColorTransform();
			}
			else {
				target.transform.colorTransform = new ColorTransform();
			}
		}
		public function reset():void
		{
			_active = false;
			handleRollOut(null);
		}
	}
}