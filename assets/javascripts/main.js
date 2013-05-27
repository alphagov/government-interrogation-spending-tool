$(document).ready(function() {
  var util = new gist.utils.Util();
  util.load_visualisations();
});

var gist = gist || {};
gist.utils = gist.utils || (function() {
  var util_obj = function util() {};

  $.extend(util_obj.prototype, {

    load_visualisations : function() {

      if ($("#chart").length != 0) {
        var that = this,
            table_data = this.load_data_from_table('data-table');
        $(".visualisation").each(function(index, node) {
          if ($(node).hasClass('treemap')) { that.draw_tree_map(node, table_data); }
        });
      }
    },

    load_data_from_table : function(table_id) {
      return [];
    },

    draw_tree_map : function(node, chart_data) {
      new gist.charts.treemap.Widget(node, { chart_data: null }).draw(940, 400);
    }

  });

  return {
    Util : util_obj
  };
})();