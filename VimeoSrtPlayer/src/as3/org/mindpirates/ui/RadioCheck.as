package org.mindpirates.ui
{
	public class RadioCheck extends HoverButton
	{
		public function RadioCheck()
		{
			addChild( new Shape_RadioDefault() );
			addChild( new Shape_RadioSelected() );
			
			super(); 
		}
	}
}