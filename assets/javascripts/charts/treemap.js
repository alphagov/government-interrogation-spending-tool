var gist = gist || {};
gist.charts = gist.charts || {};

gist.charts.treemap = gist.charts.treemap || (function() {
  var util = new gist.utils.Util();

  var treemap_d3js = util.inherit(function treemap(_node, opts) {
    treemap_d3js._super.constructor.call(this, _node, $.extend({}, gist.charts.treemap.Widget.default_options, opts));
    this.chart_type = 'treemap';
  }, gist.charts.BaseChart);

  $.extend(treemap_d3js, {
    default_options : {
      max_percentile_bar_for_other : 0.5,
      min_percentile_bar_for_other : 0.0
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

        var sorted_filtered_data = this.util.filter_sort_data(this.opts.chart_data),
            percentile_bar_for_other_scale = d3.scale.linear().domain([956, 368]).range([this.opts.min_percentile_bar_for_other, this.opts.max_percentile_bar_for_other]),
            percentile_bar_for_other = percentile_bar_for_other_scale(width),
            data = this.util.group_data_by_percentile_lowest(sorted_filtered_data, percentile_bar_for_other);

        if (!data || data.length == 0) {
          return null;
        }

        var root = {
          name: "",
          total: 0.0,
          children: data
        };

        var treemap = d3.layout.treemap()
              .size([width, height])
              .sticky(true)
              .value(function(d) { return d.total; })
              .sort(function(a, b) {
                return a.value - b.value;
              }),
            div = d3.select("#" + node_id).append("div")
              .style("position", "relative")
              .style("width", (width + margin.left + margin.right) + "px")
              .style("height", (height + margin.top + margin.bottom) + "px")
              .style("left", margin.left + "px")
              .style("top", margin.top + "px"),
            nodes = div.datum(root).selectAll(".node")
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
                  that._click_link(d.url);
                }
              })
              .style("background", function(d) { return d.children ? null : d.colour ? d.colour : that.opts.default_colour; });

            divs = nodes
              .append('div')
                .attr("class", "treemap-label")
                .style("width", function(d) { return Math.max(0, d.dx - 1) + "px"; })
                .style("height", function(d) { return Math.max(0, d.dy - 1) + "px"; })
                .style("color", function(d) { return d.children ? null : d.fontColour ? d.fontColour : that.opts.default_font_colour; })
                .html(function(d) {
                  return that.generate_label_html(d); });

        that._setupTooltips(nodes, that);
      }
    },

    generate_label_html : function(d) {
      var font_classes =     ["none","ellipsis","small","medium","large","x-large"],
          font_classes_key = [0     ,1         ,2      ,3       ,4      ,5],
          dx_font = d3.scale.threshold().domain([20,50,130,200,250]).range(font_classes_key),
          dy_font = d3.scale.threshold().domain([10,40,100,150,200]).range(font_classes_key),
          font_class_x = dx_font(d.dx),
          font_class_y = dy_font(d.dy),
          font_class = font_class_x < font_class_y ? font_classes[font_class_x] : font_classes[font_class_y];
          label_div = "",
          height = (Math.max(0, d.dy - 1));

      if (font_class == "none") {
        label_div = "";
      } else if (font_class == "ellipsis") {
        label_div = "<div style='text-align:center'>...</div>";
      } else {
        var total_by_magnitude = this.util.format_number_by_magnitude(d.total, true),
            label_text = d.abbr ? d.abbr : d.name,
            name_div = font_class_y > 2 ? "<div>" + label_text + "</div>" : "<div class='nowrap'>" + label_text + "</div>",
            value_div = "<div class='amount'>" + total_by_magnitude.value + total_by_magnitude.suffix + "</div>";
        if (font_class_y > 3) {
          value_div = "<div class='amount'>" + total_by_magnitude.value + "</div>" +
                      "<div class='bold'>" + total_by_magnitude.long_suffix + "</div>";
        }
        label_div = "<div class='" + font_class + "'>" + name_div + value_div + "</div>";
      }
      return label_div;
    }
  });

  return {
    Widget : treemap_d3js
  };
})();