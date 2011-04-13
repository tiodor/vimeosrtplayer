package org.mindpirates.websubs.ui.vimeo.sidedock
{
	import de.derhess.video.vimeo.VimeoPlayer;
	
	public class EmbedButton extends SidedockButton
	{
		public function EmbedButton(player:VimeoPlayer)
		{
			super(player);
			
			var icon:EmbedIcon = new EmbedIcon();
			artwork.addChild(icon);
			
			toggles = true;
			text = "EMBED";
			
		}
	}
}