(function() { 
	var api_name = 'srtapi';
	if (api_name in window) {
		return;
	}
	window[api_name] = {
		listeners: [],
		/**
		* Registers an event listener
		* @param swf The target VimeoSrtPlayer swf object, can be a string (object id) or an object (the actual swf object or its jQuery object)
		* @param type The even name
		* @param handler A function that will be invoked when the event occurs. The evnt object will be passed along as well as the swf id
		*/
		addListener: function(swf, type, handler) {		
			var msg = function(info) { return '[subapi.addListener] '+info; };	
			swf = typeof swf === 'string' ? $('#'+swf)[0] : swf instanceof jQuery ? swf[0] : swf;	
			if (!swf) {
				throw msg('SWF object not found: '+swf);
			} 
			if ((typeof handler) !== 'function') {
				throw msg('Handler is not a function: '+handler);
			}
			this.listeners.push({
				'swf': swf,
				'type': type,
				'handler': handler
			});
			//console.log( msg('Listener added: ') );
			//console.log( this.listeners[this.listeners.length-1] );
		},
		/**
		* Removes a listener
		* returns false if the listener could not be removed
		*/
		removeListener: function(swf, type, handler) {
			var self = this;
			swf = typeof swf === 'string' ? $('#'+swf)[0] : swf instanceof jQuery ? swf[0] : swf;
			$(this.listeners).each(function(i,obj) {
				if (obj.swf === swf && obj.type === type && obj.handler === handler) {
					self.listeners.splice(i, 1);
					return true;
				}
			});
			return false;
		},
		secondsToString: function( totalSec ) {
			var hours = parseInt( totalSec / 3600 ) % 24;
			var minutes = parseInt( totalSec / 60 ) % 60;
			var seconds = Math.round( (totalSec % 60)*1000 )/1000;
			if (seconds.toString().length == 4) {
				seconds += " ";
			}			
			var result = (hours < 10 ? "0" + hours : hours) + ":" + (minutes < 10 ? "0" + minutes : minutes) + ":" + (seconds  < 10 ? "0" + seconds : seconds);
			return result;
		},
		// 08:05:11:24
		stringToSeconds: function(string) { 
			var secs = 0;
			var p = string.split(':');
			var hh = Number(p[0]);
			var mm = Number(p[1]);
			var ss = Number(p[2].split('.')[0]);
			var ms = Number(p[2].split('.')[1]);
			secs += ss + (mm*60) + (hh*3600) + (ms/100);
			console.log(hh+':'+mm+':'+ss+':'+ms)
			return secs
		} 
	};
	window.onSrtPlayerEvent = function(player_id, type, e) {  
		//console.log(type)
		$(window[api_name].listeners).each(function(i,obj) { 
			if (obj.type === type && obj.swf === $('#'+player_id)[0]) {  
				obj.handler.apply(window, [e, player_id]); 
			}
		});
	};
})()