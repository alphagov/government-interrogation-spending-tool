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
        spyOn(util,'draw_tree_map');
        spyOn(util,'draw_barchart');
        spyOn(util,'draw_doughnut');

        util.load_visualisations();
      });

      it("should call load_from_table", function () {
        expect(util.load_data_from_table).toHaveBeenCalled();
      });

      it("should call draw against the treemap", function () {
        expect(util.draw_tree_map).toHaveBeenCalled();
      });

      it("should call draw against the barchart", function () {
        expect(util.draw_barchart).toHaveBeenCalled();
      });

      it("should call draw against the doughnut", function () {
        expect(util.draw_doughnut).toHaveBeenCalled();
      });
    });
  });

  describe("load_visualisations", function () {

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

        expect(table_data[0].name).toEqual("TEST COMMISSION")
        expect(table_data[0].total).toEqual("40")
        expect(table_data[0].url).toEqual("test-commission")

        expect(table_data[1].name).toEqual("TEST OFFICE")
        expect(table_data[1].total).toEqual("360")
        expect(table_data[1].url).toEqual("test-office")
      });
    });
  });

});