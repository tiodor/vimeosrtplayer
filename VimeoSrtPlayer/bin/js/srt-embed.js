
//  Default swf attributes
var attributes = {
	bgcolor:"#000000" ,
	id: swf_id,
	name: swf_id ,
	allowScriptAccess:"always",
	allowFullScreen:"true"
};
 
// Default swf params
var params = {
	wmode: "window"
}  
 
// VimeoSrtPlayer options
var flashVars = {
	swfId: swf_id, // must match the id attribute of the swf object
	vimeoId: vimeo_id, 
	srt: srt_url,
	localization: defaultLocalization,
	srtFontSize: 14
}; 

var embedHandler = function(e) {
	if (e.success) {
		srtPlayer = $('#'+swf_id)[0];
				
		
	}
	else {
		throw "'"+swf_id+"' not embedded!";
	}
	
} 
 
 
/*

onSubtitleApiReady = function(id) {
	var onPlay = function() {
		console.log('received play event');
	}
	srtplayer.addListener(id, 'play', onPlay);	
}*/
swfobject.embedSWF(
	swf_url, 
	swf_container_id, 
	"400", "225", 
	"10.0.0", "swf/expressInstall.swf", 
	flashVars, params, attributes, embedHandler);
 
