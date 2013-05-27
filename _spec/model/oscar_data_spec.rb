# encoding: utf-8
require_relative "../../_processors/model/oscar_data.rb"

describe "OscarData" do
	before :all do
		@oscar_data1 = OscarData.new(
			"CABINET OFFICE",
			"DEL",
			"Cabinet Office",
      "PAY (RECOVERY OF COSTS)",
			"Qtr3 - 12-13",
			"Dec-12",
			64)
	end

	describe "#new" do
		it "takes 7 parameters and returns a OscarData object" do
			@oscar_data1.should be_an_instance_of OscarData
		end
	end
	describe "#organisation" do
    	it "returns the correct organisation" do
        	@oscar_data1.organisation.should eql "CABINET OFFICE"
    	end
	end
	describe "#control_budget_code" do
    	it "returns the correct control_budget_code" do
        	@oscar_data1.control_budget_code.should eql "DEL"
    	end
	end
  describe "#segment_department_long_name" do
      it "returns the correct segment_department_long_name" do
          @oscar_data1.segment_department_long_name.should eql "Cabinet Office"
      end
  end
	describe "#economic_category_long_name" do
    	it "returns the correct economic_category_long_name" do
        	@oscar_data1.economic_category_long_name.should eql "PAY (RECOVERY OF COSTS)"
    	end
	end
	describe "#quarter" do
    	it "returns the correct quarter" do
        	@oscar_data1.quarter.should eql "Qtr3 - 12-13"
    	end
	end
	describe "#month" do
    	it "returns the correct month" do
        	@oscar_data1.month.should eql "Dec-12"
    	end
	end
	describe "#amount" do
    	it "returns the correct amount" do
        	@oscar_data1.amount.should eql 64
    	end
	end
  describe "to_s" do
    it "return string version of object" do
      @oscar_data1.to_s.include?(@oscar_data1.organisation).should be_true
      @oscar_data1.to_s.include?(@oscar_data1.control_budget_code).should be_true
      @oscar_data1.to_s.include?(@oscar_data1.segment_department_long_name).should be_true
      @oscar_data1.to_s.include?(@oscar_data1.economic_category_long_name).should be_true
      @oscar_data1.to_s.include?(@oscar_data1.quarter).should be_true
      @oscar_data1.to_s.include?(@oscar_data1.month).should be_true
      @oscar_data1.to_s.include?(@oscar_data1.amount.to_s).should be_true
    end
  end
end