$(document).ready(function() {
  var util = new gist.utils.Util();
  util.load_visualisations();
});

var gist = gist || {};
gist.utils = gist.utils || (function() {
  var util_obj = function util() {};

  $.extend(util_obj.prototype, {

    inherit: function(C, Base) {
      var F = function() {};
      F.prototype = Base.prototype;
      C.prototype = new F();
      C._super = Base.prototype;
      C.prototype.constructor = C;
      return C;
    },

    load_visualisations : function() {
      var chart_id = "chart";

      if ($("#" + chart_id).length != 0) {
        var that = this,
            table_data = this.load_data_from_table('data-table'),
            selections = [];

        $(".visualisation").each(function(index, node) {
          if ($(node).hasClass('treemap')) { that.draw_tree_map(node, table_data);  selections.push({ id: node.id, label: "area", title: "view data as an area map"}); }
          if ($(node).hasClass('barchart')) { that.draw_barchart(node, table_data); selections.push({ id: node.id, label: "bar", title: "view data as a bar chart" }); }
          if ($(node).hasClass('doughnut')) { that.draw_doughnut(node, table_data); selections.push({ id: node.id, label: "doughnut", title: "view data as a doughnut chart" }); }
        });

        if (selections.length > 0) {
          this.draw_chart_selector(chart_id, selections);
        }
      }
    },

    load_data_from_table : function(table_id) {
      var table_data = [];

      if ($("#" + table_id).length != 0) {
        $("#" + table_id + " > tbody > tr").each(function(index, node) {
          table_data.push($(this).data())
        });
      }

      return table_data;
    },

    draw_tree_map : function(node, chart_data) {
      new gist.charts.treemap.Widget(node, { chart_data: chart_data }).draw(node.offsetWidth, 407);
    },

    draw_barchart : function(node, chart_data) {
      new gist.charts.barchart.Widget(node, { chart_data: chart_data }).draw(node.offsetWidth, 400);
    },

    draw_doughnut : function(node, chart_data) {
      new gist.charts.doughnut.Widget(node, { chart_data: chart_data }).draw(node.offsetWidth, 400);
    },

    draw_chart_selector : function(chart_div_id, selections) {
      var chart_div = $("#" + chart_div_id),
          selector_div = $("<div class='chart-selector'>");

      for (var i = 0; i < selections.length; i++) {
        selector_div.append(
          $("<a href='#'>")
            .attr("title", selections[i].title)
            .attr("data-show-id", selections[i].id)
            .text(selections[i].label)
            .click(function() {
              $(".visualisation").hide();
              $("#" + $(this).attr("data-show-id")).show();
            })
        );
        if (i < selections.length-1) {
          selector_div.append(" | ")
        }
        if (i != 0) { $("#" + selections[i].id).hide(); }
      }
      chart_div.prepend(selector_div);
    }
  });

  return {
    Util : util_obj
  };
})();