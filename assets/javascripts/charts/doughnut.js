var gist = gist || {};
gist.charts = gist.charts || {};

gist.charts.doughnut = gist.charts.doughnut || (function() {
  var doughnut_d3js = function doughnut(_node, opts) {
    this.opts = $.extend({}, gist.charts.doughnut.Widget.default_options, opts);
    this.node = _node;

    this._init();
  };

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

    draw : function(w, h) {
      var that = this,
          node_id = this.node.id,
          margin = {top: 0, right: 0, bottom: 0, left: 0},
          width = w - margin.left - margin.right,
          height = h - margin.top - margin.bottom;

      this.width = w;
      this.height = h;

      if (this.opts.chart_data) {
        console.log("doughnut!")
      }
    }
  });

  return {
    Widget : doughnut_d3js
  };
})();