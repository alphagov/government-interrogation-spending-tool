var gist = gist || {};
gist.charts = gist.charts || {};

gist.charts.barchart = gist.charts.barchart || (function() {
  var util = new gist.utils.Util();

  var barchart_d3js = util.inherit(function barchart(_node, opts) {
    barchart_d3js._super.constructor.call(this, _node, $.extend({}, gist.charts.barchart.Widget.default_options, opts));
  }, gist.charts.BaseChart);

  $.extend(barchart_d3js, {
    chart_type: 'barchart',
    default_options : {
      chart_data : null,
      auto_resize : true
    }
  });

  $.extend(barchart_d3js.prototype, {
    _init : function() {
      var that = this;

      if (this.opts.auto_resize) {
        $(window).on('resize', function() {
          that._onWindowResize();
        });
      }
    },

    draw : function(w, h) {
      var that = this,
          node_id = this.node.id,
          margin = {top: 10, right: 0, bottom: 50, left: 50},
          width = w - margin.left - margin.right,
          height = h - margin.top - margin.bottom,
          bar_settings = { min_bar_g_w: 50, max_bar_g_w: 100, bar_left_m: 5 };

      this.width = w;
      this.height = h;

      if (this.opts.chart_data) {
        $("#" + node_id).empty();

        var data = this.opts.chart_data.filter(function(d) { return d.total > 0; })
          .sort(function(a,b) {return (a.total < b.total)? 1 : (a.total == b.total)? 0 : -1; });

        var max_y = d3.max(data, function(d) { return d.total });
        var y = d3.scale.linear().domain([0, max_y]).range([height, 0]);

        var svg = d3.select("#" + node_id).append("svg:svg")
          .attr("width", w)
          .attr("height", h);

        var y_axis = d3.svg.axis()
          .scale(y)
          .orient("left")
          .ticks(5)
          .tickSize(-width);

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
            return "translate(" + (margin.left + i*bar_settings.min_bar_g_w) + "," + margin.top + ")"; });

        var bar = bars.append("rect")
          .attr('class', 'actual')
          .attr("x", bar_settings.bar_left_m)
          .attr("y", function(d) { return y(d.total); })
          .attr("width", bar_settings.min_bar_g_w - bar_settings.bar_left_m)
          .attr("height", function(d) { return height - y(d.total); })
          .attr("fill", "#0075B9");

        bars.append("svg:text")
          .attr("x", bar_settings.bar_left_m + bar_settings.min_bar_g_w/2)
          .attr("y", height + 20)
          .attr('text-anchor', 'middle')
          .text(function(d) { return d.name; });
      }
    }
  });

  return {
    Widget : barchart_d3js
  };
})();