describe("Util", function() {

  var util = new gist.utils.Util();

  describe("load_visualisations", function () {

    describe("when there is no chart div on page", function () {
      it("should not call load_from_table", function () {
        spyOn(util,'load_data_from_table').andReturn([]);

        util.load_visualisations();

        expect(util.load_data_from_table).not.toHaveBeenCalled();
      });
    });

    describe("when there is a chart div on page", function () {
      beforeEach(function () {
        loadFixtures('visualisation-divs.html');
        spyOn(util,'load_data_from_table').andReturn([]);
        spyOn(util,'remove_chart_image');
        spyOn(util,'draw_tree_map');
        spyOn(util,'draw_barchart');
        spyOn(util,'draw_doughnut');
        spyOn(util,'draw_chart_selector');

        util.load_visualisations();
      });

      it("should call load_from_table", function () {
        expect(util.load_data_from_table).toHaveBeenCalled();
      });

      it("should call remove_chart_image", function () {
        expect(util.remove_chart_image).toHaveBeenCalled();
      });

      it("should call draw for the treemap", function () {
        expect(util.draw_tree_map).toHaveBeenCalled();
      });

      it("should call draw for the barchart", function () {
        expect(util.draw_barchart).toHaveBeenCalled();
      });

      it("should call draw for the doughnut", function () {
        expect(util.draw_doughnut).toHaveBeenCalled();
      });

      it("should call draw for the chart selector", function () {
        expect(util.draw_chart_selector).toHaveBeenCalled();
      });
    });
  });

  describe("remove_chart_image", function () {
    it("should remove the chart image ", function () {
      loadFixtures('visualisation-divs.html');
      util.remove_chart_image()
      expect($("#chart-image").length).toEqual(0)
    });
  });

  describe("load_from_table", function () {

    describe("when there is no data-table on page", function () {
      it("should return empty", function () {
        var table_data = util.load_data_from_table("does-not-exist")
        expect(table_data).toEqual([])
      });
    });

    describe("when there is a data-table on page", function () {
      beforeEach(function () {
        loadFixtures('data-table.html');
      });
      it("should return an array of object literals representing the table rows", function () {
        var table_data = util.load_data_from_table("data-table")
        expect(table_data.length).toEqual(2)

        expect(table_data[0].name).toEqual("CO")
        expect(table_data[0].total).toEqual(40)
        expect(table_data[0].url).toEqual("co")
        expect(table_data[0].colour).toEqual("#0078ba")
        expect(table_data[0].fontColour).toEqual("#fff")

        expect(table_data[1].name).toEqual("HMRC")
        expect(table_data[1].total).toEqual(360)
        expect(table_data[1].url).toEqual("hmrc")
        expect(table_data[1].colour).toEqual("")
        expect(table_data[1].fontColour).toEqual("")
      });
    });
  });

  describe("draw_chart_selector", function () {
    it("should insert a div into chart div above visualisation divs containing selector links", function () {
      loadFixtures('visualisation-divs.html');
      var selections = [
        { id: "test1", label: "label1", title: "title1"},
        { id: "test2", label: "label2", title: "title2"}];

      util.draw_chart_selector("chart", selections);
      expect($('div.chart-selector')).toExist();
      expect($('a')).toExist();
    });
  });

  describe("filter_sort_data", function() {
    it("should filter zero/negative values and sort by descending order", function () {
      var data = [
        { total: -1 },
        { total: 1 },
        { total: 0 },
        { total: 2 }
      ];

      var sorted_filtered_data = util.filter_sort_data(data);
      expect(sorted_filtered_data.length).toEqual(2);
      expect(sorted_filtered_data[0].total).toEqual(2);
      expect(sorted_filtered_data[1].total).toEqual(1);
    });
  });

  describe("group_data_to_max_num_items_by_lowest", function() {
    describe("when there is less than the max number before grouping", function () {
      it("should return the data without grouping", function () {
        var data = [
          { title: "4", total: 4 },
          { title: "3", total: 3 },
          { title: "2", total: 2 },
          { title: "1", total: 1 }
        ],
        max_number_of_items = 5;

        var grouped_data = util.group_data_to_max_num_items_by_lowest(data, max_number_of_items);
        expect(grouped_data.length).toEqual(4);
        expect(grouped_data[0].total).toEqual(4);
      });
    });
    describe("when there is more than the max number before grouping", function () {
      it("should return the data with the lowest values grouped into a single object other", function () {
        var data = [
          { title: "7", total: 7 },
          { title: "6", total: 6 },
          { title: "5", total: 5 },
          { title: "4", total: 4 },
          // should total following
          { title: "3", total: 3 },
          { title: "2", total: 2 },
          { title: "1", total: 1 }
        ],
        max_number_of_items = 5;

        var grouped_data = util.group_data_to_max_num_items_by_lowest(data, max_number_of_items);

        expect(grouped_data.length).toEqual(max_number_of_items);
        expect(grouped_data[4].total).toEqual(6);
        expect(grouped_data[4].title).toEqual("Other");
      });
    });
  });
/*
  describe("group_data_by_percentile_lowest", function() {
    it("should return the data unchanged if there is less than 3 items", function () {
      var data = [
        { title: "2", total: 2 },
        { title: "1", total: 1 }
      ],
      percentile_bar = 0.1;

      var grouped_data = util.group_data_by_percentile_lowest(percentile_bar)
      expect(grouped_data.length).toEqual(2);
      expect(grouped_data[0].total).toEqual(2);
      expect(grouped_data[1].total).toEqual(1);
    });
    it("should return the data with items below the percentile bar grouped into a single object other", function () {
      var data = [
        { title: "10a", total: 10 },
        { title: "10b", total: 10 },
        { title: "10c", total: 10 },
        { title: "10d", total: 10 },
        { title: "10e", total: 10 },
        { title: "2", total: 2 },
        { title: "1a", total: 1 },
        { title: "1b", total: 1 },
      ],
      percentile_bar = 0.1;

      var grouped_data = util.group_data_by_percentile_lowest(percentile_bar)
      expect(0).toEqual(1);
    });
  });
*/
});




