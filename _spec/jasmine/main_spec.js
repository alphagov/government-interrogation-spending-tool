
describe("main", function() {

	var theSort = new table_sorter.sort.Sort();

	beforeEach(function() {
		spyOn(theSort,'load_table_sort').andReturn([]);
		spyOn(theSort,'initiate_custom_parser_for_sorting');
		spyOn(theSort,'initialize_the_table_sorter');
		spyOn(theSort,'change_direction_arrow_for_acending_decending');

		loadFixtures('data-table.html');


    theSort.load_table_sort();
    theSort.initiate_custom_parser_for_sorting();
    theSort.initialize_the_table_sorter();

	});


	it("should call load_table_sort", function () {
	  expect(theSort.load_table_sort).toHaveBeenCalled();
	});

	it("should call initiate_custom_parser_for_sorting", function () {
	  expect(theSort.initiate_custom_parser_for_sorting).toHaveBeenCalled();
	});

	it("should call initialize_the_table_sorter", function () {
	  expect(theSort.initialize_the_table_sorter).toHaveBeenCalled();
	});

});