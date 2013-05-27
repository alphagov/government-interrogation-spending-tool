var gist = gist || {};
gist.charts = gist.charts || {};

gist.charts.treemap = gist.charts.treemap || (function() {
  var treemap_d3js = function treemap(_node, opts) {
    this.opts = $.extend({}, gist.charts.treemap.Widget.default_options, opts);
    this.node = _node;
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
      console.log("treemap init");
      var that = this;
    },

    draw : function(w, h) {
      console.log("treemap draw");
    }
  });

  return {
    Widget : treemap_d3js
  };
})();