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
 