package org.mindpirates.websubs.ui.vimeo.sidedock
{
	import de.derhess.video.vimeo.VimeoPlayer;
	import de.derhess.video.vimeo.VimeoPlayerUI;
	
	import org.mindpirates.video.interfaces.IVimeoPlayer;

	public class ShareButton extends SidedockButton
	{
		public function ShareButton(player:VimeoPlayer)
		{
			super(player);
			
			var icon_fb:logo_fb_14 = new logo_fb_14();
			artwork.addChild(icon_fb);
			
			var icon_tw:logo_tw_14 = new logo_tw_14();
			artwork.addChild(icon_tw);
			
			icon_tw.x = icon_fb.width + 3;
			
			toggles = true;
			
			text  = 'SHARE';
			
		}
	}
}