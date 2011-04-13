package org.mindpirates.websubs.ui
{
	import flash.utils.describeType;
	
	import org.mindpirates.video.interfaces.IVideoPlayer;
	import org.osflash.thunderbolt.Logger;

	public class TooltipOptions extends Object
	{
		public function TooltipOptions()
		{
			super();
		}
		public var bgAlpha:Number = 0.8;
		public var dropShadow:Boolean = true;
		public var player:IVideoPlayer;
		public var delay:Number = 500;		
		public var bgColor:Number = 0x222222;
		public var textColor:Number = 0xFFFFFF;
		public var padding:Number = 2;
		public var cornerRadius:Number = 10;
		public var extraHeight:Number = 3;
		public var extraWidth:Number = 3;
		 
		public function merge(o:TooltipOptions):void {
			var varList:XMLList = describeType(o)..variable;
			for(var i:int; i < varList.length(); i++){
				this[varList[i].@name] = o[varList[i].@name]; 
			}
		}
	}
}