var gist = gist || {};
gist.charts = gist.charts || (function() {

  // Base Chart
  var base_chart = function BaseChart(_node, opts) {
    this.opts = $.extend({}, gist.charts.BaseChart.default_options, opts);
    this.node = _node;
    this.util = new gist.utils.Util();

    this.timeout_id = null;
    this._init();
  };

  $.extend(base_chart, {
    default_options : {
      chart_data : null,
      auto_resize : true,
      default_colour: "#2e358b",
      default_font_colour: "#fff",
      black_font_colour: "#0A0C0C",
    }
  });

  $.extend(base_chart.prototype, {
    _init : function() {
      var that = this;

      if (this.opts.auto_resize) {
        $(window).on('resize', function() {
          that._onWindowResize();
        });
      }
    },

    _onWindowResize : function() {
      if ($(this.node).is(':visible') == false) {
        return;
      }

      var that = this, jnode = $(this.node);

      window.clearTimeout(this.timeout_id);
      this.timeout_id = setTimeout(function() {
        var width = jnode.innerWidth();
        if (that.width != width) {
          that.draw(width, that.height);
        }
      }, 50);
    },

    _setupTooltips : function(nodes, self) {
      nodes
        .on("mouseover", function(d) { tooltip.show(self._get_tooltip_content(d, self)); })
        .on('mouseout', function(d) { tooltip.hide(); });
    },

    _get_tooltip_content : function(d, self) {
      var that = this,
          breakdown = "",
          has_breakdown_ellipsis = false;
      if (d.breakdown) {
        breakdown += "<ul>";
        d.breakdown.forEach(function(b) {
          if (b.name != "...") {
            breakdown += "<li>"
            breakdown += "<div class='label'>" + b.name + "</div>";
            breakdown += "<div>" + that.util.format_numeric_string_to_uk_format(b.total, true) + "</div>";
            breakdown += "</li>"
          } else {
            has_breakdown_ellipsis = true;
          }
        });
        breakdown += "</ul>";
        if (has_breakdown_ellipsis) {
          breakdown += "<div class='ellipsis'>...</div>";
        }
      }

      return "<h3>" + d.name + '</h3>' +
        '<div class="amount">' +
        this.util.format_numeric_string_to_uk_format(d.total, true) +
        '</div>' + breakdown;
    },

    to_short_magnitude_string : function(value)  {
      var magnitude_value = this.util.format_number_by_magnitude(value, true);
      return magnitude_value.value + magnitude_value.suffix;
    }
  });

  return {
    BaseChart: base_chart
  };
})();
