var destroyEditorExample = function() {
	$.fancybox.close();
	$('#srt-lines_wrapper').remove();
	$('#btn-create-editor').css('display','block');
	$('#btn-destroy-editor').css('display','none');
 
}

var createEditorExample = function() {
	if (!srtPlayer) {
		return;
	}
	
	$('#btn-destroy-editor').click(function() {
		destroyEditorExample();
	}); 
	$('#btn-create-editor').css('display','none');
	$('#btn-destroy-editor').css('display','block');
	
	var json_str = srtPlayer.parseSrt(); 
	var srt = jQuery.parseJSON( json_str );
	
	//------------------------------------------------------------
	// 
	// Create the table element
	// 
	//------------------------------------------------------------	
	var table = $('<table id="srt-lines">');
	
	var th = $('<thead>');
	th.appendTo(table); 
	var thr = $('<tr>');
	thr.append( $('<th class="index">id</th>') );
	thr.append( $('<th class="start">start</th>') );
	thr.append( $('<th class="end">end</th>') );
	thr.append( $('<th class="text">text</th>') );
	thr.append( $('<th class="show">show</th>') );
	thr.appendTo(th);  
	
	var tb = $('<tbody>');
	$(srt.lines).each(function(i,line) {
		var tr = $('<tr>');
		tr.append( $('<td class="index">'+i+'</td>') );
		tr.append( $('<td class="start editable">'+line.start+'</td>').attr('data-prop', 'start') );
		tr.append( $('<td class="end editable" >'+line.end+'</td>').attr('data-prop', 'end') );
		tr.append( $('<td class="text editable">'+line.text+'</td>').attr('data-prop', 'text') );
		tr.append( $('<td class="show"><button>show in video</button></td>') ); 
		tr.appendTo(tb); 
		tr.find('button').click(function() {
			var time = $(this).closest('tr').find('td[data-prop=start]').text();
			console.log('seekTo '+time) 
			srtPlayer.seekTo( time );
			srtPlayer.pause();
		});
	});
	tb.appendTo(table)
	$('#btn-create-editor').after( table );
	
	
	//------------------------------------------------------------
	// 
	// Fancybox preview layer
	// 
	//------------------------------------------------------------	
	var applyFancybox = function() {
		$('<a>').attr('href','#flashHolder').fancybox({overlayShow:false}).trigger('click');		
		$('#fancybox-wrap').draggable();		
	}
	if ($.fancybox) {
		applyFancybox()	
	} 	
	else { 
		$("head").append($("<link rel='stylesheet' href='fancybox/jquery.fancybox-1.3.4.css' type='text/css' media='screen' />")); 
		$.getScript('fancybox/jquery.fancybox-1.3.4.pack.js', applyFancybox);
	}
	
	
	//------------------------------------------------------------
	// 
	// DataTables
	// 
	//------------------------------------------------------------
	var applyDataTable = function() {
		table.dataTable({
			"bJQueryUI": true,
			"sPaginationType": "full_numbers",
			"iDisplayLength": 30
		});
		
	}
	if ($('<a>').dataTable) {
		applyDataTable();
	}
	else {
		$("head").append($("<link rel='stylesheet' href='http://ajax.googleapis.com/ajax/libs/jqueryui/1.8/themes/base/jquery-ui.css' type='text/css' media='screen' />"));   
		$("head").append($("<link rel='stylesheet' href='jquery-datatables/css/demo_table_jui.css' type='text/css' media='screen' />"));    
		$.getScript('jquery-datatables/js/jquery.dataTables.min.js',applyDataTable);
	}
  
  		
	//------------------------------------------------------------
	// 
	// uiTableEdit
	// 
	//------------------------------------------------------------
	var applyUiTableEdit = function() {$.uiTableEdit( $('#srt-lines') , {
			find:'td.editable',
			dataVerify: null,
			editDone: function(newValue, oldValue, e, td) {
				//console.log('---------------\nEDIT DONE\n---------------\n\n')
				var tr = $(td).parent();
				var prop = $(td).attr('data-prop');
				var celldata = {
					start: tr.find('td[data-prop=start]').text(),
					end: tr.find('td[data-prop=end]').text(),
					text: tr.find('td[data-prop=text]').text()
				};
				var oldLine = {
					start: prop=='start' ? oldValue : celldata.start,
					end: prop=='end' ? oldValue : celldata.end,
					text: prop=='text' ? oldValue : celldata.text
				};
				var newLine = {
					start: prop=='start' ? newValue : celldata.start,
					end: prop=='end' ? newValue : celldata.end,
					text: prop=='text' ? newValue : celldata.text
				};
				var matchLine = function(obj1,obj2) {
					for (var a in obj1) {
						if (obj1[a] != obj2[a]) {
							return false;
						}
					}
					return true;
				}
				$(srt.lines).each(function(i) {
					if ( matchLine(srt.lines[i], oldLine) ) {
						if (!matchLine(oldLine, newLine)) {
							//console.log('------------ change ---------------')
							//console.log(oldLine)
							//console.log(newLine)
							srtPlayer.changeLine(oldLine, newLine);
							srt.lines[i] = newLine;
						}
					}	 
				})
			}
		});				
	};
	$.getScript('js/jquery.uitableedit.js', applyUiTableEdit);	
	return;
	 
}
createEditorExample();