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
          margin = {top: 0, right: 0, bottom: 20, left: 0},
          width = w - margin.left - margin.right,
          height = h - margin.top - margin.bottom,
          bar_settings = {
            font_size: 16,
            min_bar_g_w: 50,
            max_bar_g_w: 50,
            bar_left_m: 5,
            bar_bottom_m: 5,
            label_m: 10 };

      this.width = w;
      this.height = h;

      if (this.opts.chart_data) {
        $("#" + node_id).empty();

        var max_number_of_bars = Math.floor(height/(bar_settings.min_bar_g_w*1.0)),
            data = this.util.filter_sort_data(this.opts.chart_data),
            data = this.util.group_data_to_max_num_items_by_lowest(data, max_number_of_bars),
            largest_total_label_size = d3.max(data, function(d) { return that.util.calculate_text_size(d.totalLabel, bar_settings.font_size); }),
            chart_width = width - (largest_total_label_size + bar_settings.bar_left_m + 5 ),
            x_axis_m_scale = d3.scale.linear().domain([368, 856]).range([200, 428]),
            max_x_axis_size = x_axis_m_scale(chart_width),
            largest_x_axis_size = d3.max(data, function(d) { return that.util.calculate_text_size(d.name, bar_settings.font_size); }),
            x_axis_margin = (largest_x_axis_size + 20) < max_x_axis_size ? largest_x_axis_size + 20 : max_x_axis_size,
            max_bar_width = chart_width - x_axis_margin,
            bar_g_w = Math.floor(height /(data.length*1.0)),
            bar_g_w = (bar_g_w < bar_settings.max_bar_g_w)? bar_g_w : bar_settings.max_bar_g_w,
            bar_w = bar_g_w - bar_settings.bar_bottom_m,
            max_x = d3.max(data, function(d) { return d.total }),
            x = d3.scale.linear().domain([0, max_x]).range([0, max_bar_width]),
            ticks_scale = d3.scale.linear().domain([150, 500]).range([2, 5]),
            number_of_bars = data.length,
            actual_height = (number_of_bars * bar_g_w) + margin.top + margin.bottom;

        data.forEach(function(d) { d.x = x(d.total); });

        var svg = d3.select("#" + node_id).append("svg:svg")
          .attr("width", w)
          .attr("height", actual_height);

        var x_axis = d3.svg.axis()
          .scale(x)
          .ticks(ticks_scale(max_bar_width))
          .tickSize(actual_height - margin.bottom)
          .tickFormat(function(value) {
            return that.to_short_magnitude_string(value);
          });

        svg.append("g")
          .attr("class", "x axis")
          .attr("transform", "translate(" + margin.left + x_axis_margin + ",0)")
          .call(x_axis);

        var bars = svg.append('g')
          .attr('class','bars')
          .selectAll("g.node")
          .data(data)
          .enter()
          .append("g")
          .attr('class','bar')
          .attr("transform", function(d, i) {
            return "translate(" + margin.left + x_axis_margin + "," + (margin.top + i*bar_g_w) + ")"; });

        var bar = bars.append("rect")
          .attr("x", 0)
          .attr("y", 0)
          .attr("width", function(d) { return d.x; })
          .attr("height", bar_w)
          .attr("fill", function(d) { return d.colour ? d.colour : that.opts.default_colour; });

        var x_axis_text = bars.append("svg:text")
          .attr("x", -bar_settings.bar_left_m)
          .attr("y", (bar_settings.bar_bottom_m + bar_g_w)/2)
          .attr("text-anchor", "end")
          .attr('fill', that.opts.black_font_colour)
          .text(function(d) { return that.util.truncate_text_for_available_space(d.name, x_axis_margin - bar_settings.bar_left_m, bar_settings.font_size); });

        var total_text = bars.append("svg:text")
          .attr("x", function(d) { return d.x + bar_settings.bar_left_m; })
          .attr("y", (bar_settings.bar_bottom_m + bar_g_w)/2)
          .attr('fill', that.opts.black_font_colour)
          .attr('class', 'amount')
          .text(function(d) { return d.totalLabel; });

        var hitboxes = bars.append("rect")
          .attr('class', 'hitbox')
          .attr("x", -x_axis_margin)
          .attr("y", 0)
          .attr('width', w)
          .attr('height', bar_w)
          .style("cursor", function(d) { return d.url ? "pointer" : ""; })
          .on("click", function(d) {
            if (d.url) {
              window.location = d.url;
            }
          });

        that._setupTooltips(hitboxes, that);
      }
    }
  });

  return {
    Widget : barchart_d3js
  };
})();