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

        util.load_visualisations();
      });

      it("should call load_from_table", function () {
        expect(util.load_data_from_table).toHaveBeenCalled();
      });

      it("should call draw against the treemap", function () {
        expect(util.draw_tree_map).toHaveBeenCalled();
      });
    });
  });

});