# encoding: utf-8
require_relative "../../_processors/model/qds_data.rb"

describe QdsData do
	before :all do
		@qds_data1 = QdsData.new(
			"FCO",
			"Quarter 2 - 2012/13",
			"Spend by Budget Type",
			"Organisation's Own Budget (DEL)",
			"Organisation's Own Budget (DEL), Sub-Total",
			425.345)
	end

	describe "#new" do
		it "takes 6 parameters and returns a QdsData object" do
			@qds_data1.should be_an_instance_of QdsData
		end
	end
	describe "#parent_department" do
    	it "returns the correct parent_department" do
        	@qds_data1.parent_department.should eql "FCO"
    	end
	end
	describe "#report_date" do
    	it "returns the correct report date" do
        	@qds_data1.report_date.should eql "Quarter 2 - 2012/13"
    	end
	end
	describe "#section" do
    	it "returns the correct section" do
        	@qds_data1.section.should eql "Spend by Budget Type"
    	end
	end
	describe "#data_headline" do
    	it "returns the correct data headline" do
        	@qds_data1.data_headline.should eql "Organisation's Own Budget (DEL)"
    	end
	end
	describe "#data_sub_type" do
    	it "returns the correct data sub type" do
        	@qds_data1.data_sub_type.should eql "Organisation's Own Budget (DEL), Sub-Total"
    	end
	end
	describe "#value" do
    	it "returns the correct value" do
        	@qds_data1.value.should eql 425.345
    	end
	end
  describe "to_s" do
    it "return string version of object" do
      @qds_data1.to_s.include?(@qds_data1.parent_department).should be_true
      @qds_data1.to_s.include?(@qds_data1.report_date).should be_true
      @qds_data1.to_s.include?(@qds_data1.section).should be_true
      @qds_data1.to_s.include?(@qds_data1.data_headline).should be_true
      @qds_data1.to_s.include?(@qds_data1.data_sub_type).should be_true
      @qds_data1.to_s.include?(@qds_data1.value.to_s).should be_true
    end
  end
end