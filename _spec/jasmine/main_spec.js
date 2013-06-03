describe("when page loads", function() {

    beforeEach(function() {
    });

    it("Should add and event to the headings of the table", function(){
      var spyEvent = spyOnEvent('table#data-table thead tr th', 'click');
      $('table#data-table thead tr th').click();
      expect('click').toHaveBeenTriggeredOn('table#data-table thead tr th');
      expect(spyEvent).toHaveBeenTriggered();
    });

  });