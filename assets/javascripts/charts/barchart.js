var gist = gist || {};
gist.charts = gist.charts || {};

gist.charts.barchart = gist.charts.barchart || (function() {
  var util = new gist.utils.Util();

  var barchart_d3js = util.inherit(function barchart(_node, opts) {
    barchart_d3js._super.constructor.call(this, _node, $.extend({}, gist.charts.barchart.Widget.default_options, opts));
  }, gist.charts.BaseChart);

  $.extend(barchart_d3js, {
    chart_type: 'barchart',
    default_options : {}
  });

  $.extend(barchart_d3js.prototype, {
    draw : function(w, h) {
      var that = this,
          node_id = this.node.id,
          margin = {top: 10, right: 0, bottom: 10, left: 70},
          width = w - margin.left - margin.right,
          height = h - margin.top - margin.bottom,
          bar_settings = { min_bar_g_w: 50, max_bar_g_w: 100, bar_left_m: 5, label_m: 10 };

      this.width = w;
      this.height = h;

      if (this.opts.chart_data) {
        $("#" + node_id).empty();

        var max_number_of_bars = Math.floor(width/(bar_settings.min_bar_g_w*1.0)),
            data = this.util.filter_sort_data(this.opts.chart_data),
            data = this.util.group_data_to_max_num_items_by_lowest(data, max_number_of_bars),
            bar_g_w = Math.floor(width /(data.length*1.0)),
            bar_g_w = (bar_g_w < bar_settings.max_bar_g_w)? bar_g_w : bar_settings.max_bar_g_w,
            max_y = d3.max(data, function(d) { return d.total }),
            y = d3.scale.linear().domain([0, max_y]).range([height, 0]);

        var svg = d3.select("#" + node_id).append("svg:svg")
          .attr("width", w)
          .attr("height", h);

        var y_axis = d3.svg.axis()
          .scale(y)
          .orient("left")
          .ticks(5)
          .tickSize(-width)
          .tickFormat(function(value) {
            return that.to_short_magnitude_string(value);
          });

        svg.append("g")
          .attr("class", "y axis")
          .attr("transform", "translate(" + margin.left + "," + margin.top + ")")
          .call(y_axis);

        var bars = svg.append('g')
          .attr('class','bars')
          .selectAll("g.node")
          .data(data)
          .enter()
          .append("g")
          .attr('class','bar')
          .attr("transform", function(d, i) {
            return "translate(" + (margin.left + i*bar_g_w) + "," + margin.top + ")"; });

        var bar = bars.append("rect")
          .attr('class', 'actual')
          .attr("x", bar_settings.bar_left_m)
          .attr("y", function(d) { return y(d.total); })
          .attr("width", bar_g_w - bar_settings.bar_left_m)
          .attr("height", function(d) { return height - y(d.total); })
          .attr("fill", function(d) { return d.colour ? d.colour : that.opts.default_colour; });

        bars.append("svg:text")
          .attr("x", (bar_settings.bar_left_m + bar_g_w)/2)
          .attr("y", function(d) { return y(d.total) + bar_settings.label_m; })
          .style("writing-mode", "tb")
          .attr('fill', function(d) { return d.fontColour ? d.fontColour : that.opts.default_font_colour; })
          .text(function(d) { return that.to_short_magnitude_string(d.total) + " " + d.name; });
      }
    }
  });

  return {
    Widget : barchart_d3js
  };
})();