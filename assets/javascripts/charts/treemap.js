var gist = gist || {};
gist.charts = gist.charts || {};

gist.charts.treemap = gist.charts.treemap || (function() {
  var util = new gist.utils.Util();

  var treemap_d3js = util.inherit(function treemap(_node, opts) {
    treemap_d3js._super.constructor.call(this, _node, $.extend({}, gist.charts.treemap.Widget.default_options, opts));
  }, gist.charts.BaseChart);

  $.extend(treemap_d3js, {
    chart_type: 'treemap',
    default_options : {
      percentile_bar_for_other : 0.3
    }
  });

  $.extend(treemap_d3js.prototype, {
    draw : function(w, h) {
      var that = this,
          node_id = this.node.id,
          margin = {top: 0, right: 0, bottom: 0, left: 0},
          width = w - margin.left - margin.right,
          height = h - margin.top - margin.bottom;

      this.width = w;
      this.height = h;

      if (this.opts.chart_data) {
        $("#" + node_id).empty();

        var data = this.util.filter_sort_data(this.opts.chart_data),
            data = this.util.group_data_by_percentile_lowest(data, this.opts.percentile_bar_for_other);

        var root = {
          name: "",
          total: 0.0,
          children: data
        };

        var treemap = d3.layout.treemap()
              .size([width, height])
              .sticky(true)
              .value(function(d) { return d.total; }),
            div = d3.select("#" + node_id).append("div")
              .style("position", "relative")
              .style("width", (width + margin.left + margin.right) + "px")
              .style("height", (height + margin.top + margin.bottom) + "px")
              .style("left", margin.left + "px")
              .style("top", margin.top + "px"),
            node = div.datum(root).selectAll(".node")
              .data(treemap.nodes)
              .enter().append("div")
              .attr("class", "node")
              .call(function() {
                this.style("left", function(d) { return d.x + "px"; })
                    .style("top", function(d) { return d.y + "px"; })
                    .style("width", function(d) { return Math.max(0, d.dx - 1) + "px"; })
                    .style("height", function(d) { return Math.max(0, d.dy - 1) + "px"; })
                    .style("cursor", function(d) { return d.url ? "pointer" : ""; });
              })
              .on("click", function(d) {
                if (d.url) {
                  window.location = d.url;
                }
              })
              .style("background", function(d) { return d.children ? null : d.colour ? d.colour : that.opts.default_colour; })
              .append('span')
                .style("color", function(d) { return d.children ? null : d.fontColour ? d.fontColour : that.opts.default_font_colour; })
                .html(function(d) {
                  return that.generate_label_html(d); });
      }
    },

    generate_label_html : function(d) {
      var magnitude_value = this.util.format_number_by_magnitude(d.total, true),
          name_div = "<div>" + d.name + "</div>",
          value_div = "<div>" + magnitude_value.value + magnitude_value.suffix + "</div>",
          label_div = name_div + value_div;
      return label_div;
    }
  });

  return {
    Widget : treemap_d3js
  };
})();