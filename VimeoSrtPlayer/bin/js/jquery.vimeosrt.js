/*globals window, console, swfobject, jQuery*/
(function($){
	$.fn.vimeosrt = function(options) {
		// define variables
		var iframe, o, src, vimeo_id, query_params, container, 
			swf_id, swf_attributes, swf_params, swf_flashVars, swf_embedHandler;
		 
		// validate iframe element 
		iframe = $(this);
		if (iframe[0].tagName.toLowerCase() !== 'iframe') {
			if (window.hasOwnProperty('console')) { console.error(this+' is not an iframe!'); }
			return;
		} 
		
		// ensure global players array exists
		if (!window.hasOwnProperty('vimeosrtplayers')) {
			window.vimeosrtplayers = [];
		}
		
		// apply options
		o = $.extend({}, $.fn.vimeosrt.defaults, options);
		
		// shortcut to iframe source url
		src = iframe.attr('src');
		
		if (src.indexOf(o.vimeo_player) !== -1) {
			
			/**
			 * Appends a time query param if usecache is set to false in options.
			 */
			var url = function(value) {
				if (o.usecache) {
					return value;
				}
				return value + '?time=' + new Date().getTime();
			};
			
			vimeo_id = src.split(o.vimeo_player)[1].split('?')[0];	
			query_params = src.split('?')[1];
			//------------------------------------------------------------------
			// 
			// create the container div
			//
			//------------------------------------------------------------------
			container = $('<div>').attr({
				id: 'VimeoSrt_'+vimeo_id
			}).css({
				width: iframe.width(),
				height: iframe.height()
			}).insertBefore(iframe);
			
			
			//------------------------------------------------------------------
			// 
			// embed VimeoSrtPlayer.swf
			//
			//------------------------------------------------------------------
			swf_id = 'VimeoSrtPlayer_'+vimeo_id;  
			
			swf_attributes = {
				bgcolor: "#000000",
				id: swf_id,
				name: swf_id,
				allowScriptAccess: "always",
				allowFullScreen: "true"
			}; 
			
			swf_params = {
				wmode: "window"
			};
			
			swf_flashVars = {
				swfId: swf_id,
				vimeoId: vimeo_id, 
				srt: url(o.srt),
				localization: url(o.srtlist),
				lang: o.lang,
				srtFontSize: o.fontsize,
				srtMargin: o.margin,
				queryParams: escape(query_params),
				dynpos: o.dynpos
			}; 
			
			swf_embedHandler = function(e) {  
				if (e.success) {
					//console.log(vimeo_id+' -> '+$('#'+swf_id)[0]);
					window.vimeosrtplayers.push($('#'+swf_id)[0]);
				}
				else {
					throw "'"+o.swf+"' not embedded!";
				}
				
			};
			
			var do_embed = function() {
				swfobject.embedSWF(url(o.swf), container.attr('id'), iframe.width(), iframe.height(), "10.0.0", o.expressInstall, swf_flashVars, swf_params, swf_attributes, swf_embedHandler);
				iframe.attr('src', 'about:blank');
				iframe.remove();
			}
			
			if (window.hasOwnProperty('swfobject')) {
				do_embed();
			}
			else { 
    			jQuery.getScript('http://ajax.googleapis.com/ajax/libs/swfobject/2.2/swfobject.js', do_embed);
			}
			 
		}
	};
	
	$.fn.vimeosrt.defaults = {
		/** the part of iframe src before the vimeo id appears */ 
		vimeo_player: 'http://player.vimeo.com/video/', 
		
		/** use cached versions of files vs always load fresh */
		usecache: true, 
		
		/** VimeoSrtPlayer swf file */
		swf: 'swf/VimeoSrtPlayer.swf', 
		
		/** an srt file to be loaded on startup */
		srt: '', 
		
		/** an xml file with further srts */
		srtlist: '', 
		
		/** default language code when srtlist is specified */
		lang: '', 
		
		/* subtitle font size in pixels */
		fontsize: 21, 
		
		/** subtitle bottom margin in pixels */
		margin: 30, 
		
		/** expressInstall.swf path or url */
		expressInstall: 'swf/expressInstall.swf',
		
		/** whether or not the subtitle position should change when the vimeo UI (playbar) appears/disappears */
		dynpos: true
	};
	
})(jQuery);