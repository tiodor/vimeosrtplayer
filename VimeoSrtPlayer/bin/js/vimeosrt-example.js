/**
 * VimeoSrtPlayer example
 * @author Jovica Aleksic
 */


	
embedSrtPlayer(_GET('id'), _GET('srt'));
	
$(document).ready(function() {
		 
		
	initQuickTestExample(_GET('id'), _GET('srt'));
	
});


//--------------------------------------------------------------------------
// 
// helper functions
// 
//-------------------------------------------------------------------------- 
 
/**
 * Retrieves url query paramseter values.
 * @param name The name of the query parameter
 */ 
function _GET( name )
{
	name = name.replace(/[\[]/,"\\\[").replace(/[\]]/,"\\\]");
	var regexS = "[\\?&]"+name+"=([^&#]*)";
	var regex = new RegExp( regexS );
	var results = regex.exec( window.location.href );
	if( results == null )
		return "";
	else
		return decodeURIComponent(results[1].replace(/\+/g, " "));
}


//--------------------------------------------------------------------------
// 
// embedding the flash file via swfobject
// 
//-------------------------------------------------------------------------- 

var srtPlayer = null;

SrtEvent = {
	MOOGALOOP_READY: 'moogaloopReady',
	MOOGALOOP_ERROR: 'moogaloopError',
	SRT_LOADED: 'srtLoaded',
	SRT_ERROR: 'srtError',
	LOAD_SRT: 'loadSrt',
	FULLSCREEN_CHANGED: 'fullscreenChanged',
	LOAD_LOCALIZATION: 'loadLocalization',
	LOCALIZATION_ERROR: 'localizationError',
	LOCALIZATION_LOADED: 'localizationLoaded',
	LANGUAGE_CHANGED: 'languageChanged',
	VOLUME_CHANGED: 'volumeChanged',
	PLAY: 'play',
	PAUSE: 'pause',
	SEEK: 'seek',
	SUBTITLE_TEXT: 'subtitleText'
};

function onPlayerEmbedded() {
	srtPlayer = $('#VimeoSrtPlayer')[0];
} 

function onPlayerEvent(type, event) {
	switch (type) {
		case SrtEvent.MOOGALOOP_READY: 
			console.log('moogaloop ready, video duration: '+event.duration+'s, url: '+event.moogaloopUrl);
			break;
		case SrtEvent.LOAD_SRT:
			console.log('load srt file: '+event.srtUrl);
			break;
		case SrtEvent.SRT_LOADED:
			console.log('srt loaded, url: '+event.srtUrl);
			break;
		case SrtEvent.SRT_ERROR:
			console.log('srt failed, url: '+event.srtUrl);
			break;
		case SrtEvent.FULLSCREEN_CHANGED:
			console.log('fullscreen changed, fullscreen: '+event.fullscreen);
			break;
		case SrtEvent.LOAD_LOCALIZATION:
			console.log('load localization file, url: '+event.localizationUrl);
			break;
		case SrtEvent.LOCALIZATION_LOADED:
			console.log('localization file loaded, url: '+event.localizationUrl);
			break;
		case SrtEvent.LOAD_LOCALIZATION:
			console.log('localization file failed, url: '+event.localizationUrl);
			break;
		case SrtEvent.LANGUAGE_CHANGED:
			console.log('language changed, language: '+event.langName+' ('+event.lang+')');
			break;
		case SrtEvent.VOLUME_CHANGED:
			console.log('volume changed, volume: '+event.volume);
			break;
		case SrtEvent.PLAY:
			console.log('play, position: '+event.position);
			break;
		case SrtEvent.PAUSE:
			console.log('pause, position: '+event.position);
			break;
		case SrtEvent.SEEK:
			console.log('seek, new position: '+event.position);
			break;
		case SrtEvent.SUBTITLE_TEXT:
			console.log('new subtitle text: '+event.text);
			break;
	}
}
 
 
function embedSrtPlayer(vimeo, srt) {
	
	vimeo = vimeo || 14960254;
	srt = srt || "srt/example.srt";   
	 
	// VimeoSrtPlayer options
	var flashVars = {
		swfId: 'VimeoSrtPlayer', // must match the id of the swf object!!!!
		vimeoId: vimeo, 
		srt: srt,
		localization: "srt/subtitles.xml?time="+new Date().getTime(),
		srtFontSize: 14
	}; 
	//  Default swf attributes
	var attributes = {
		bgcolor:"#000000" ,
		id:"VimeoSrtPlayer" ,
		name:"VimeoSrtPlayer" ,
		allowScriptAccess:"always",
		allowFullScreen:"true"
	};
	 
	// Default swf params
	var params = {
		wmode: "window"
	}  
	 
	var embedHandler = function(e) {
		if (e.success) {
			onPlayerEmbedded();
		}
		else {
			throw "SWF not embedded!";
		}
		
	} 
	swfobject.embedSWF("swf/VimeoSrtPlayer.swf?time="+new Date().getTime(), "flashContent", "400", "225", "10.0.0", "swf/expressInstall.swf", flashVars, params, attributes, embedHandler);
	
}

//--------------------------------------------------------------------------
// 
// Example: Quick Test
// 
//-------------------------------------------------------------------------- 

function initQuickTestExample(vimeo, srt) { 
	$('#vimeo_id').val(vimeo);
	$('#srt_url').val(srt);
	$('#apply').click(function() {
		var url = $(location).attr('href').split('?')[0];
		url += '?id='+$('#vimeo_id').val();
		url += '&srt='+$('#srt_url').val();
		$(location).attr('href', url);
	});
	$('#clear').click(function() {
		$(location).attr('href', $(location).attr('href').split('?')[0]);
	});
	$('input').keydown(function(event) {
		if (event.keyCode == '13') {
			$('#apply').click();
		}
	});
}

