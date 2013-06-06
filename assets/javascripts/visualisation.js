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

        this.remove_chart_image();

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

    remove_chart_image : function() {
      $("#chart-image").remove();
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
    },

    filter_sort_data : function(data) {
      return data.filter(function(d) { return d.total > 0; }).sort(function(a,b) {return (a.total < b.total)? 1 : (a.total == b.total)? 0 : -1; });
    },

    group_data_to_max_num_items_by_lowest : function(data, max_number_of_items) {
      if (data.length < max_number_of_items) {
        return data;
      } else {
        var sorted = data.sort(function(a,b) {return (a.total < b.total)? 1 : (a.total == b.total)? 0 : -1; }),
            other_group = sorted.slice(max_number_of_items-1),
            other_item = { name: "Other", total: 0, colour: "#e2e2e2", fontColour: "#231f20" };

        other_group.forEach(function(item) {
          other_item.total += item.total;
        });
        var result = sorted.slice(0, max_number_of_items-1);
        result.push(other_item);

        return result;
      }
    },

    group_data_by_percentile_lowest : function(data, percentile_bar) {
      if (data.length <= 2) {
        return data;
      } else {
        var values = data.map(function(d) { return d.total; }),
            sorted_values = values.sort(d3.ascending),
            quantile = d3.quantile(sorted_values, percentile_bar),
            result = [],
            other_item = { name: "Other", total: 0, colour: "#e2e2e2", fontColour: "#231f20" },
            other_count = 0;

        data.forEach(function(d) {
          if (d.total >= quantile) {
            result.push(d);
          } else {
            other_item.total += d.total;
            other_count += 1;
          }
        });
        result.push(other_item);

        return (other_count > 1)? result : data;
      }
    }
  });

  return {
    Util : util_obj
  };
})();