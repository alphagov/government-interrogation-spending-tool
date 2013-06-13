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
      min_percentile_bar_for_other : 0.7
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
            percentile_bar_for_other_scale = d3.scale.linear().domain([368, 956]).range([this.opts.min_percentile_bar_for_other, this.opts.max_percentile_bar_for_other]),
            percentile_bar_for_other = percentile_bar_for_other_scale(width),
            data = this.util.group_data_by_percentile_lowest(data, percentile_bar_for_other);

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

        // ellipsis treemap labels
        $(".treemap-label").dotdotdot({ ellipsis: '...', wrap: 'letter' });
      }
    },

    generate_label_html : function(d) {
      var font_classes = ["none","ellipsis","small","medium","large","x-large"],
          font_sizes = {
            "small" : 16,
            "medium" : 19,
            "large" : 24,
            "x-large" : 24,
          },
          dx_font = d3.scale.threshold().domain([20,50,130,200,250]).range(font_classes),
          dy_number_of_lines = d3.scale.threshold().domain([20,40,80,100]).range([0,1,2,3,99]),
          font_class = dx_font(d.dx),
          number_of_lines = dy_number_of_lines(d.dy)
          label_div = "",
          height = (Math.max(0, d.dy - 1));

      if (number_of_lines == 0 || font_class == "none") {
        label_div = "";
      } else if (font_class == "ellipsis") {
        label_div = "<div style='text-align:center'>...</div>";
      } else if (number_of_lines == 1) {
        font_class = "small";
        label_div = "<div class='" + font_class + "'>" + d.name + " - <em>" + d.totalLabel + "</em></div>";
      } else {
        var font_size = font_sizes[font_class],
            truncated_total = this.util.truncate_text_for_available_space(d.totalLabel? d.totalLabel: "", d.dx, font_size);
        name_div = "<div>" + d.name + "</div>";
        value_div = "<div class='amount'>" + truncated_total + "</div>";

        label_div = "<div class='" + font_class + "'>" + name_div + value_div + "</div>";
      }

      return label_div;
    }
  });

  return {
    Widget : treemap_d3js
  };
})();