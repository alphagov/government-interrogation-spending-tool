var page = require('webpage').create(),
    system = require('system'),
    t, address;

if (system.args.length === 2) {
    console.log('Usage: _phantomjs_generate_chart_image.js <some URL> <some file path>');
    phantom.exit();
}

t = Date.now();
address = system.args[1];
output_file = system.args[2],
chart_id = "chart",

page.onError = function (msg, trace) {
  console.log(msg);
  trace.forEach(function(item) {
      console.log('  ', item.file, ':', item.line);
  })
}

page.open(address, function (status) {
  if (status !== 'success') {
    console.log('FAIL to load the address');
  } else {
    t = Date.now() - t;
    console.log('Loading time ' + t + ' msec');

    try {
      var dims = page.evaluate(function(chart_id) {
        var chart_sel = '#' + chart_id,
          jbody = $('body'),
          jchart = $(chart_sel),
          margin = 0;

        if (jchart.length !== 0) {
          jchart.css('width', jchart.width() + 'px');
          jbody.append(jchart)
              .children().slice(0,-1).remove();

          $('body, html').css({ 'background-color': '#fff', 'margin': 0, 'padding': 0 });

          jchart.css({ 'margin': "0 0 0 0" });
          jbody.find("#chart .chart-selector").remove();

          return {
            width: jchart.width() + margin*2,
            height: jchart.height() + margin*2
          };
        } else {
          console.log('Unable to find the chart!: ', jbody.html());
          return null;
        }
      }, chart_id);

      if (dims !== null) {
        page.clipRect = { top: 0, left: 0, width: dims.width, height: dims.height };
        page.render(output_file);
        console.log('Saved file ' + output_file);
      } else {
        console.log('Error rendering page');
      }
    } catch (e) {
      console.log('Error rendering page' + e);
    }
  }
  phantom.exit();
});