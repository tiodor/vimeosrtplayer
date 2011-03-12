package org.mindpirates.utils
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	
	import org.osflash.thunderbolt.Logger;

	public class ChildLogger 
	{
		public function ChildLogger()
		{
		}
		public static function info(target:DisplayObjectContainer):void { 
			var result:String = ' --------- ChildLogger report ---------\n';
			result += 'children of '+target.toString()+'\n';
			for (var i:int=0; i<target.numChildren; i++) {
				result+= i+'. '+target.getChildAt(i).toString()+'\n';
			}
			Logger.info(result)
		}
	}
}