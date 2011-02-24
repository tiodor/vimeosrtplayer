package org.mindpirates.ui
{
	import com.bumpslide.util.ImageUtil;
	import com.gskinner.utils.Janitor;
	
	import de.loopmode.graphics.Rect;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.FullScreenEvent;
	import flash.events.MouseEvent;
	
	import org.osflash.thunderbolt.Logger;
	
	[Event(name="close", type="flash.events.Event")]
	public class Popup extends Sprite
	{
		 
		public var bg:Rect;
		public var content:Rect;
		public var btnClose:CloseButton;
		public var titleField:DejaVuText;
		private var _yoffset:Number = 0;
		private var _xoffset:Number = 0;
		private var _title:String;
		private var _padding:Number = 10;
		private var _titleText:String;
		private var _logo:DisplayObject;
		
		public function Popup(w:Number, h:Number)
		{
			super(); 
			
			bg = new Rect(1, 1, 0x000000, 0.8, 0);
			addChild(bg);
			
			content = new Rect(w, h, 0x333333);
			addChild(content);
			 
			titleField = new DejaVuText();
			titleField.selectable = false; 
			content.addChild(titleField);
			
			btnClose = new CloseButton(17,7,0x222222,0x555555); 
			btnClose.addEventListener(MouseEvent.CLICK, handleCloseClick, false, 0, true);
			addChild(btnClose);
			
			
			
			addEventListener(Event.ADDED_TO_STAGE, handleAddedToStage, false, 0, true); 
		}
		
		//-------------------------------------------------------------
		//
		// getters / setters
		//
		//-------------------------------------------------------------
		
		
		
		public function set logo(value:DisplayObject):void
		{
			if (_logo) {
				content.removeChild( _logo );
			}
			_logo = value;
			ImageUtil.resize(_logo, 15,15, false);
			content.addChild(_logo);
			draw();
		}
		
		public function get logo():DisplayObject
		{
			return _logo;
		}
		
		public function set yoffset(value:Number):void
		{
			_yoffset = value;
		}
		
		public function get yoffset():Number
		{
			return _yoffset
		}
		
		public function set xoffset(value:Number):void
		{
			_xoffset = value;
		}
		
		public function get xoffset():Number
		{
			return _xoffset
		}
		
		public function set padding(value:Number):void
		{
			_padding = value;
			draw();
		}
		public function get padding():Number
		{
			return _padding;
		}
		
		
		public function set title(value:String):void
		{ 
			_titleText = value;
			titleField.text = value;
			draw();
		}
		public function get title():String
		{
			return _titleText;
		}
		
		
		//-------------------------------------------------------------
		//
		// Event handlers
		//
		//-------------------------------------------------------------
		
		private function handleAddedToStage(e:Event):void
		{
			center();
			draw();
			stage.addEventListener(FullScreenEvent.FULL_SCREEN, handleFullScreenChange, false, 0, true);
		}
		private function handleFullScreenChange(e:FullScreenEvent):void
		{
			draw()
			center();
		}
		private function handleCloseClick(e:Event):void
		{
			close();	
		}
		//-------------------------------------------------------------
		//
		// methods
		//
		//-------------------------------------------------------------
		 
		public function draw():void
		{ 
			if (!stage) {
				return;
			}  
			titleField.x = _padding;
			titleField.y = _padding;
			bg.width = stage.stageWidth;
			bg.height = stage.stageHeight;
			btnClose.x = _xoffset + content.x + content.width - btnClose.width - _padding;
			btnClose.y = _yoffset + content.y + _padding;
			if (logo) {
				logo.x = _padding;
				logo.y = _padding;
				titleField.x = logo.x + logo.width + 2;
			}
		}
		public function center():void
		{ 
			if (!stage) {
				return;
			}  
			content.x = (stage.stageWidth - content.width)/2 + xoffset;
			content.y = (stage.stageHeight - content.height)/2 + yoffset; 
			draw();
		}
		
		public function close():void
		{ 
			dispatchEvent( new Event( Event.CLOSE ) );
			new Janitor(this).cleanUp();
		}
		 
	}
}