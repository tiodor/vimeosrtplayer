/**
 * VimeoSrtPlayer AS & JS
 * @author Jovica Aleksic
 */

 
/**
 * Retrieves url query paramseter values.
 * Found on http://stackoverflow.com/questions/901115/get-querystring-values-with-jquery
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

var defaultVimeoId = 14960254; // Old Fish Jazz band, Kevin Klein
var defaultSrt = 'srt/example.srt';
var defaultLocalization = "srt/subtitles.xml?time="+new Date().getTime(); 

var swf_container_id = 'flashContent';
var swf_id = 'VimeoSrtPlayer';
var swf_url = 'swf/VimeoSrtPlayer.swf?time='+new Date().getTime();

var srtPlayer = null;	 
var vimeo_id = _GET('id') || defaultVimeoId;
var srt_url = _GET('srt') || defaultSrt;
    

$(document).ready(function() {
	
	// embedding the player
	$.getScript('js/srt-embed.js');
	
	
	
	
	// editor example
	$('#btn-create-editor').click(function() {
		$.getScript('js/srt-editor.js');
	});
	
	
	
	
	// form to change vimeo id or srt url
	$('#vimeo_id').val(vimeo_id);
	$('#srt_url').val(srt_url);
	$('#apply').click(function() {
		var url = $(location).attr('href').split('?')[0];
		url += '?id='+$('#vimeo_id').val();
		url += '&srt='+$('#srt_url').val();
		$(location).attr('href', url);
	});
	$('#clear').click(function() {
		$(location).attr('href', $(location).attr('href').split('?')[0]);
	});
	$('.quick-test input').keydown(function(event) {
		if (event.keyCode == '13') {
			$('#apply').click();
		}
	});
	 
});


 