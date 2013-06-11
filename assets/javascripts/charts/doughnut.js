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
      max_percentile_bar_for_other : 0.6,
      min_percentile_bar_for_other : 0.8
    }
  });

  $.extend(doughnut_d3js.prototype, {
    draw : function(w, h) {
      var that = this,
          node_id = this.node.id,
          margin = {top: 0, right: 0, bottom: 0, left: 0},
          width = w - margin.left - margin.right,
          height = h - margin.top - margin.bottom,
          section_width = width / 2,
          diameter = Math.min(section_width, height),
          radius = diameter / 2;

      this.width = w;
      this.height = h;

      if (this.opts.chart_data) {
        $("#" + node_id).empty();

        var filtered_data = this.util.filter_sort_data(this.opts.chart_data),
            percentile_bar_for_other_scale = d3.scale.linear().domain([184, 428]).range([this.opts.min_percentile_bar_for_other, this.opts.max_percentile_bar_for_other]),
            percentile_bar_for_other = percentile_bar_for_other_scale(radius),
            data = this.util.group_data_by_percentile_lowest(filtered_data, percentile_bar_for_other),
            total_spend_label = "Total Spend",
            total_spend_text = this.get_total_spend_text(data);

        var chart_div = d3.select("#" + node_id)
          .append("div")
          .attr("class", "col-50-no-media");

        var tooltip_div = d3.select("#" + node_id)
          .append("div")
          .style("width", diameter + "px")
          .style("height", diameter + "px")
          .attr("class", "col-50-no-media doughnut-tooltips");

        d3.select("#" + node_id)
          .append("div")
          .style("clear", "both");

        var svg = chart_div.append("svg:svg")
          .attr("width", diameter)
          .attr("height", diameter);

        var chart_g = svg.append("g")
          .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

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
            .style("fill", function(d) { return d.colour ? d.colour : that.opts.default_colour; })
            .style("cursor", function(d) { return d.url ? "pointer" : ""; })
            .on("click", function(d) {
              if (d.url) {
                window.location = d.url;
              }
            });

        var ring_text = vis.append("g")
        ring_text.append("text")
          .attr('text-anchor', 'middle')
          .attr('class', 'header-label')
          .attr('y', -20)
          .text("Total spend");
        ring_text.append('text')
          .attr('text-anchor', 'middle')
          .attr('class', 'header')
          .attr('y', 20)
          .text(total_spend_text);

        this.setupTooltips(tooltip_div, vis.selectAll("path"));
        this.draw_tooltip(tooltip_div, total_spend_label, total_spend_text);
      }
    },

    setupTooltips : function(tooltip_div, paths) {
      var that = this;
      paths.on("mouseover", function(d) { that.draw_tooltip(tooltip_div, d.name, d.total); })
    },

    draw_tooltip : function(tooltip_div, name, value) {
      tooltip_div.selectAll("ul").remove();

      var list = tooltip_div.append('ul');
      list.append('li').attr('class', 'label').text("Name");
      list.append('li').text(name);
      list.append('li').attr('class', 'label').text("Spend");
      list.append('li').text(value);
    },

    get_total_spend_text : function(data) {
      var total_elem_text = $('#total').text();

      if (total_elem_text == '') {
        var total = d3.sum(data, function(d) { return d.total; }),
            magnitude_value = this.util.format_number_by_magnitude(total, true);
        total_elem_text = magnitude_value.value + magnitude_value.suffix;
      }

      return total_elem_text;
    }

  });

  return {
    Widget : doughnut_d3js
  };
})();