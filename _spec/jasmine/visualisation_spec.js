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
});




