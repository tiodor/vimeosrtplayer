package org.mindpirates.utils
{
	import flash.external.ExternalInterface;

	public class BrowserUtil
	{
		public function BrowserUtil()
		{
		}
		
		/**
		 * Returns window.location.href from JavaScript
		 */
		public static function get url():String
		{
			return ExternalInterface.call('function(){return window.location.href;}',null);
		}
		
		/**
		 * Returns the fraction of the url after #
		 */
		public static function get hash():String
		{
			var u:String = url;
			var h:String = null;
			if (u.indexOf('#')!=-1) {
				h = u.split('#')[1];
			}
			return h;
		}
		
		/**
		 * Returns the value for a hash param.<br>
		 * Example: if there is "/#someParam=1" in the url, hashParam('someParam') would return '1'
		 */
		public static function hashParam(name:String):String
		{
			var result:String = null;
			if (url.indexOf('#'+name+'=')!=-1) {
				result = url.split('#'+name+'=')[1]
			}
			return result;
		}
	}
}