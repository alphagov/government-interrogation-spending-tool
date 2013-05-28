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
          if ($(node).hasClass('barchart')) { that.draw_barchart(node, table_data); }
          if ($(node).hasClass('doughnut')) { that.draw_doughnut(node, table_data); }
        });
      }
    },

    load_data_from_table : function(table_id) {
      var table_data = [],
          row_data = {};

      if ($("#" + table_id).length != 0) {
        $("#" + table_id + " > tbody > tr").each(function(index, node) {
          row_data = {};

          row_data.name = $(this).attr('data-name');
          row_data.total = $(this).attr('data-total');
          row_data.url = $(this).attr('data-url');

          table_data.push(row_data)
        });
      }

      return table_data;
    },

    draw_tree_map : function(node, chart_data) {
      new gist.charts.treemap.Widget(node, { chart_data: chart_data }).draw(node.offsetWidth, 400);
    },

    draw_barchart : function(node, chart_data) {
      new gist.charts.barchart.Widget(node, { chart_data: chart_data }).draw(node.offsetWidth, 400);
    },

    draw_doughnut : function(node, chart_data) {
      new gist.charts.doughnut.Widget(node, { chart_data: chart_data }).draw(node.offsetWidth, 400);
    }

  });

  return {
    Util : util_obj
  };
})();