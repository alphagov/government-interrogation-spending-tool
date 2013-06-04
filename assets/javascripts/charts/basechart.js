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
      other_colour: "#e2e2e2",
      other_font_colour: "#231f20",
      default_colour: "#2e358b",
      default_font_colour: "#fff"
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
    }
  });

  return {
    BaseChart: base_chart
  };
})();
