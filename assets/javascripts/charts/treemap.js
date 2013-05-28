var gist = gist || {};
gist.charts = gist.charts || {};

gist.charts.treemap = gist.charts.treemap || (function() {
  var treemap_d3js = function treemap(_node, opts) {
    this.opts = $.extend({}, gist.charts.treemap.Widget.default_options, opts);
    this.node = _node;

    this._init();
  };

  $.extend(treemap_d3js, {
    chart_type: 'treemap',
    default_options : {
      chart_data : null,
      auto_resize : true
    }
  });

  $.extend(treemap_d3js.prototype, {
    _init : function() {
      var that = this;
    },

    draw : function(w, h) {
      var that = this,
          node_id = this.node.id,
          margin = {top: 0, right: 0, bottom: 0, left: 0},
          width = w - margin.left - margin.right,
          height = h - margin.top - margin.bottom;

      if (this.opts.chart_data) {
        var root = {
          name: "/",
          total: 0.0,
          children: this.opts.chart_data
        };

        var color = d3.scale.category20c(),
            treemap = d3.layout.treemap()
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
              .style("background", function(d) { return d.children ? null : d3.rgb(color(d.name)).darker(); })
              .append('span').html(function(d) { return d.children ? null : d.name + ' - <em>' + d.total + '</em>'; });
      }
    }
  });

  return {
    Widget : treemap_d3js
  };
})();