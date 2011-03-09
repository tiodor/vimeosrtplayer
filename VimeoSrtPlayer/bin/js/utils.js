 
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
