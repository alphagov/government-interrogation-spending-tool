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

  describe "quarter_short" do
    it "returns a formatted short quarter string" do
      OscarData.quarter_short("Qtr4 - 11-12").should eq "Q4 2011"
      OscarData.quarter_short("Qtr1 - 12-13").should eq "Q1 2012"
      OscarData.quarter_short("Qtr2 - 12-13").should eq "Q2 2012"
      OscarData.quarter_short("Qtr3 - 12-13").should eq "Q3 2012"
      OscarData.quarter_short("Qtr4 - 12-13").should eq "Q4 2012"
    end
  end
  describe "quarter_long" do
    it "returns a formatted long quarter string" do
      OscarData.quarter_long("Qtr4 - 11-12").should eq "Quarter 4 2011"
      OscarData.quarter_long("Qtr1 - 12-13").should eq "Quarter 1 2012"
      OscarData.quarter_long("Qtr2 - 12-13").should eq "Quarter 2 2012"
      OscarData.quarter_long("Qtr3 - 12-13").should eq "Quarter 3 2012"
      OscarData.quarter_long("Qtr4 - 12-13").should eq "Quarter 4 2012"
    end
  end
end