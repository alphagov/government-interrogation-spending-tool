$(document).ready(function() {
  var util = new table_sorter.sort.Sort();
  util.load_table_sort();
});


var table_sorter = table_sorter || {};
table_sorter.sort = table_sorter.Sort || (function() {
  var sort_obj = function sort() {};

  $.extend(sort_obj.prototype, {

    load_table_sort : function(){
      this.initiate_custom_parser_for_sorting();
      this.initialize_the_table_sorter();
      this.change_direction_arrow_for_acending_decending();
    },
    initiate_custom_parser_for_sorting : function(){
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
    },
    initialize_the_table_sorter : function(){
      $('#data-table').tablesorter({
        headers : {
          1 : { sorter: 'parseRealNumbers' }
        }
      });
    },
    change_direction_arrow_for_acending_decending : function(){
      $("#data-table").bind("sortEnd",function() {
        $(".sort-ind").remove();
        $('#data-table thead th').each(function(index){
          if($(this).hasClass("headerSortUp"))
            $(this).append('<span class="sort-ind">▼</span>');
          else if($(this).hasClass("headerSortDown"))
            $(this).append('<span class="sort-ind">▲</span>');

        });
      });
    }
  });

  return {
    Sort : sort_obj
  };
})();
