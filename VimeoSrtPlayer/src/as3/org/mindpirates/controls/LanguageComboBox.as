package org.mindpirates.controls
{ 
	import de.loopmode.utils.iso.ISO_3166_1_alpha_2;
	
	import fl.controls.ComboBox;
	import fl.data.DataProvider;
	
	import flash.display.Loader;
	import flash.net.URLRequest;
	
	import org.mindpirates.subtitles.localization.LocalizationXML;
	
	public class LanguageComboBox extends ComboBox
	{ 
		private var loaders:Array = [];
		private var data:LocalizationXML;
		public function LanguageComboBox(xml:LocalizationXML)
		{
			super();
			data = xml;   
			createItems();  
		}
		  
		private function createItems():void
		{
			var dp:Array = [];
			for each (var lang:String in ISO_3166_1_alpha_2._codes) {  
				if (data.languages.indexOf( lang ) != -1) {
					var loader:Loader = new Loader(); 		 
					loader.load( new URLRequest( data.iconsPath	+ '/' + lang + '.png' ) );   
					dp.push({label: lang, icon: loader});
				}
			}
			dataProvider = new DataProvider(dp);
		}
		  
		
	}
}