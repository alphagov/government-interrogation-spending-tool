var gist = gist || {};
gist.charts = gist.charts || {};

gist.charts.doughnut = gist.charts.doughnut || (function() {

  var util = new gist.utils.Util();

  var doughnut_d3js = util.inherit(function doughnut(_node, opts) {
    doughnut_d3js._super.constructor.call(this, _node, $.extend({}, gist.charts.doughnut.Widget.default_options, opts));
  }, gist.charts.BaseChart);

  $.extend(doughnut_d3js, {
    chart_type: 'doughnut',
    default_options : {
      chart_data : null,
      auto_resize : true
    }
  });

  $.extend(doughnut_d3js.prototype, {
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
          margin = {top: 0, right: 0, bottom: 0, left: 0},
          width = w - margin.left - margin.right,
          height = h - margin.top - margin.bottom;

      this.width = w;
      this.height = h;

      if (this.opts.chart_data) {
        $("#" + node_id).empty();

        var data = this.opts.chart_data.filter(function(d) { return d.total > 0; })
          .sort(function(a,b) {return (a.total < b.total)? 1 : (a.total == b.total)? 0 : -1; });

        var radius = Math.min(width, height) / 2;
        var svg = d3.select("#" + node_id).append("svg:svg")
          .attr("width", w)
          .attr("height", h);

        var chart_g = svg.append("g")
          .attr("transform", "translate(" + margin.left + "," + margin.top + ")")

        var vis = chart_g.append("g")
          .attr("transform", "translate(" + radius + "," + radius + ")");

        var partition = d3.layout.partition()
          .sort(null)
          .size([2 * Math.PI, radius * radius])
          .value(function(d) { return d.total; })
          .children(function(d) { return d.values; });

        var arc = d3.svg.arc()
          .startAngle(function(d) { return d.x; })
          .endAngle(function(d) { return d.x + d.dx; })
          .innerRadius(function(d) { return Math.sqrt(d.y); })
          .outerRadius(function(d,i) { return Math.sqrt(d.y + d.dy); });

        var root = { "name": "root", "values": data };

        var path = vis.data([root]).selectAll("path")
          .data(partition.nodes)
          .enter().append("path")
            .attr("display", function(d) { return d.depth ? null : "none"; }) // hide inner ring
            .attr("d", arc)
            .attr("fill-rule", "evenodd")
            .style("stroke", "#fff")
            .style("fill", function(d) { return "blue"; });
      }
    }
  });

  return {
    Widget : doughnut_d3js
  };
})();