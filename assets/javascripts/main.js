$(document).ready(function() {
  console.log("ready");
  $(".visualisation").each(function(index, node) {
    if ($(node).hasClass('treemap')) {
      new gist.charts.treemap.Widget(node, { chart_data: null }).draw(940, 400);
    }
  });
});