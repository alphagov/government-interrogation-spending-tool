
$(document).ready(function() { 

	//add a sorter for the way we display money
  $.tablesorter.addParser({ 
	  // set a unique id 
	  id: 'parseRealNumbers', 
	  is: function(s) { 
	    return false; 
	  }, 
	  format: function(s, table, cell, cellIndex) { 
	    return $(cell).attr('title');
	  }, 
	  type: 'numeric' 
	}); 

  // set up sorting and set the custom money sorter to its column
	$('#data-table').tablesorter({ 
	  headers : { 
	    1 : { sorter: 'parseRealNumbers' }
		}	
	});

	//bind adding an acending and descending marker after a click to the event of sorting so it happens after it fires
	$("#data-table").bind("sortEnd",function() { 
		$(".sort-ind").remove();
  	$('#data-table thead th').each(function(index){ 
			if($(this).hasClass("headerSortUp"))
				$(this).append('<span class="sort-ind">▼</span>');
			else if($(this).hasClass("headerSortDown"))
				$(this).append('<span class="sort-ind">▲</span>');
				
		});
  }); 

}); 

