$(document).ready(function() {
  var util = new gist.utils.Util();
  util.load_visualisations();
});

var gist = gist || {};
gist.utils = gist.utils || (function() {
  var util_obj = function util() {};

  $.extend(util_obj.prototype, {

    inherit: function(C, Base) {
      var F = function() {};
      F.prototype = Base.prototype;
      C.prototype = new F();
      C._super = Base.prototype;
      C.prototype.constructor = C;
      return C;
    },

    load_visualisations : function() {
      var chart_id = "chart";

      if ($("#" + chart_id).length != 0) {
        var that = this,
            table_data = this.load_data_from_table('data-table'),
            selections = [];

        this.remove_chart_image();

        $(".visualisation").each(function(index, node) {
          if ($(node).hasClass('treemap')) { that.draw_tree_map(node, table_data);  selections.push({ id: node.id, label: "area", title: "view data as an area map"}); }
          if ($(node).hasClass('barchart')) { that.draw_barchart(node, table_data); selections.push({ id: node.id, label: "bar", title: "view data as a bar chart" }); }
          if ($(node).hasClass('doughnut')) { that.draw_doughnut(node, table_data); selections.push({ id: node.id, label: "doughnut", title: "view data as a doughnut chart" }); }
        });

        if (selections.length > 0) {
          this.draw_chart_selector(chart_id, selections);
        }
      }
    },

    remove_chart_image : function() {
      $("#chart-image").remove();
    },

    load_data_from_table : function(table_id) {
      var table_data = [];

      if ($("#" + table_id).length != 0) {
        $("#" + table_id + " > tbody > tr").each(function(index, node) {
          table_data.push($(this).data())
        });
      }

      return table_data;
    },

    draw_tree_map : function(node, chart_data) {
      new gist.charts.treemap.Widget(node, { chart_data: chart_data }).draw(node.offsetWidth, 407);
    },

    draw_barchart : function(node, chart_data) {
      new gist.charts.barchart.Widget(node, { chart_data: chart_data }).draw(node.offsetWidth, 400);
    },

    draw_doughnut : function(node, chart_data) {
      new gist.charts.doughnut.Widget(node, { chart_data: chart_data }).draw(node.offsetWidth, 400);
    },

    draw_chart_selector : function(chart_div_id, selections) {
      var chart_div = $("#" + chart_div_id),
          selector_div = $("<div class='chart-selector'>");

      for (var i = 0; i < selections.length; i++) {
        selector_div.append(
          $("<a href='#'>")
            .attr("title", selections[i].title)
            .attr("data-show-id", selections[i].id)
            .text(selections[i].label)
            .click(function() {
              $(".visualisation").hide();
              $("#" + $(this).attr("data-show-id")).show();
            })
        );
        if (i < selections.length-1) {
          selector_div.append(" | ")
        }
        if (i != 0) { $("#" + selections[i].id).hide(); }
      }
      chart_div.prepend(selector_div);
    },

    filter_sort_data : function(data) {
      return data.filter(function(d) { return d.total > 0; }).sort(function(a,b) {return (a.total < b.total)? 1 : (a.total == b.total)? 0 : -1; });
    },

    group_data_to_max_num_items_by_lowest : function(data, max_number_of_items) {
      if (data.length <= max_number_of_items) {
        return data;
      } else {
        var sorted = data.sort(function(a,b) {return (a.total < b.total)? 1 : (a.total == b.total)? 0 : -1; }),
            other_group = sorted.slice(max_number_of_items-1),
            other_item = { name: "Other Departments", total: 0, colour: "#e2e2e2", fontColour: "#231f20" };

        other_group.forEach(function(item) {
          other_item.total += item.total;
        });
        var result = sorted.slice(0, max_number_of_items-1);
        result.push(other_item);

        return result;
      }
    },

    group_data_by_percentile_lowest : function(data, percentile_bar) {
      if (data.length <= 2) {
        return data;
      } else {
        var values = data.map(function(d) { return d.total; }),
            sorted_values = values.sort(d3.ascending),
            quantile = d3.quantile(sorted_values, percentile_bar),
            result = [],
            other_item = { name: "Other Departments", total: 0, colour: "#e2e2e2", fontColour: "#231f20" },
            other_count = 0;

        data.forEach(function(d) {
          if (d.total >= quantile) {
            result.push(d);
          } else {
            other_item.total += d.total;
            other_count += 1;
          }
        });
        result.push(other_item);

        return (other_count > 1)? result : data;
      }
    },

    format_number_by_magnitude : function(value, is_sterling) {
      var magnitudes = {
        trillion: { value:1e12, suffix:"tn", long_suffix:"trillion" },
        billion:  { value:1e9,  suffix:"bn", long_suffix:"billion" },
        million:  { value:1e6,  suffix:"m",  long_suffix:"million" },
        thousand: { value:1e3,  suffix:"k",  long_suffix:"thousand" },
        unit:     { value:1,    suffix:"",   long_suffix:"" }
      },
      magnitudeFor = function (value) {
        var abs = Math.abs(value);

        if (abs >= 1e12) return magnitudes.trillion;
        if (abs >= 1e9)  return magnitudes.billion;
        if (abs >= 1e6)  return magnitudes.million;
        if (abs >= 1e3)  return magnitudes.thousand;
        return magnitudes.unit;
      },
      magnitude = magnitudeFor(value),
      scaled_value = (value / magnitude.value),
      scaled_value_3_sigs = scaled_value.toPrecision(3),
      magnitude_value = scaled_value_3_sigs.toString().replace(/\.0+$/,"");

      if (is_sterling) {
        magnitude_value = ("£" + magnitude_value).replace("£-", "-£");
      }

      return { value:magnitude_value, suffix:magnitude.suffix, long_suffix:magnitude.long_suffix };
    },

    format_numeric_string_to_uk_format : function(numeric_string, is_sterling) {
      var parts = numeric_string.toString().split(".");
      parts[0] = parts[0].replace(/\B(?=(\d{3})+(?!\d))/g, ",");

      var formatted_value = parts.join(".");
      return is_sterling ? ("£" + formatted_value).replace("£-", "-£") : formatted_value;
    },

    calculate_text_size : function(text, font_size) {
      return Math.ceil(gist.utils.avg_font_sizes[font_size.toString()] * text.length);
    },

    truncate_text_for_available_space : function(s, width, font_size) {
      // calculated for NTA only
      var avg_font_size = gist.utils.avg_font_sizes[font_size.toString()];

      if (avg_font_size*s.length > width) {
        max_characters = Math.floor(width/avg_font_size)
        s = s.substring(0, max_characters-3) + "..."
      }

      return s;
    }
  });

  return {
    avg_font_sizes : {
        "16":8.85,
        "19":10.8
    },
    Util : util_obj
  };
})();

var tooltip=function(){
  var id = 'tt';
  var top = 7;
  var left = 7;
  var maxw = 300;
  var speed = 10;
  var timer = 20;
  var endalpha = 100;
  var alpha = 0;
  var tt,t,c,b,h;
  var ie = document.all ? true : false;
  return{
    show:function(v,w){
      if(tt == null){
        tt = document.createElement('div');
        tt.setAttribute('id',id);
        t = document.createElement('div');
        t.setAttribute('id',id + 'top');
        c = document.createElement('div');
        c.setAttribute('id',id + 'cont');
        b = document.createElement('div');
        b.setAttribute('id',id + 'bot');
        tt.appendChild(t);
        tt.appendChild(c);
        tt.appendChild(b);
        document.body.appendChild(tt);
        tt.style.opacity = 0;
        tt.style.filter = 'alpha(opacity=0)';
        document.onmousemove = this.pos;
      }
      tt.style.display = 'block';
      c.innerHTML = v;
      tt.style.width = w ? w + 'px' : 'auto';
      if(!w && ie){
        t.style.display = 'none';
        b.style.display = 'none';
        tt.style.width = tt.offsetWidth;
        t.style.display = 'block';
        b.style.display = 'block';
      }
      if(tt.offsetWidth > maxw){tt.style.width = maxw + 'px'}
      h = parseInt(tt.offsetHeight) + top;
      clearInterval(tt.timer);
      tt.timer = setInterval(function(){tooltip.fade(1)},timer);
    },
    pos:function(e){
      var u = ie ? event.clientY + document.documentElement.scrollTop : e.pageY;
      var l = ie ? event.clientX + document.documentElement.scrollLeft : e.pageX;
      tt.style.top = (u - h) + 'px';
      tt.style.left = (l + left) + 'px';
    },
    fade:function(d){
      var a = alpha;
      if((a != endalpha && d == 1) || (a != 0 && d == -1)){
        var i = speed;
        if(endalpha - a < speed && d == 1){
          i = endalpha - a;
        }else if(alpha < speed && d == -1){
          i = a;
        }
        alpha = a + (i * d);
        tt.style.opacity = alpha * .01;
        tt.style.filter = 'alpha(opacity=' + alpha + ')';
      }else{
        clearInterval(tt.timer);
        if(d == -1){tt.style.display = 'none'}
      }
    },
    hide:function(){
      clearInterval(tt.timer);
      tt.timer = setInterval(function(){tooltip.fade(-1)},timer);
    }
  };
}();