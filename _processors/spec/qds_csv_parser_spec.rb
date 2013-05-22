# encoding: utf-8
require_relative "../qds_csv_parser.rb"
require_relative "../model/qds_data.rb"

describe "QdsCsvParser" do
  before(:all) do
    @csv_parser = QdsCsvParser.new
    @log_file_path = "_processors/logs/QdsCsvParser.log"
    @sample_file_full_path = "_processors/spec/test_data/test_qds_sample.csv"
  end

  describe "#new" do
    it "takes no parameters and returns a QdsCsvParser object" do
      @csv_parser.should be_an_instance_of QdsCsvParser
    end
  end

  describe "#log_file_path" do
    it "returns the log file path" do
      @csv_parser.log_file_path.should eq @log_file_path
    end
  end

  describe "#parse_row" do
    before(:all) do
      @sample_row = ["TOY", "TOY - Core", "Quarter 2 - 2012/13", "Current Quarter", "Spending Data", "Spend by Budget Type", "Top Total", "Top Total", "Actual", "105", "A note 1"]
      @parse_row_result = @csv_parser.parse_row(@sample_row)
    end
    
    it "raises ArgumentError if row has less than 11 rows" do
      expect { 
          @csv_parser.parse_row((1..10).to_a.collect{ |i| i.to_s })
      }.to raise_error(ArgumentError)
    end

    it "returns a qds_data object" do
      @parse_row_result.should be_an_instance_of QdsData
    end

    it "object populated with values" do
      @parse_row_result.parent_department.should eq "TOY"
      @parse_row_result.report_date.should eq "Quarter 2 - 2012/13"
      @parse_row_result.section.should eq "Spend by Budget Type"
      @parse_row_result.data_headline.should eq "Top Total"
      @parse_row_result.data_sub_type.should eq "Top Total"
      @parse_row_result.value.should eq 105
    end
  end

  describe "#parse_file" do
    before(:all) do
      @parse_file_results = @csv_parser.parse_file(@sample_file_full_path)
    end 
  
    it "creates a log file containing logging messages" do
      File.exist?(@log_file_path).should be_true
      File.readlines(@log_file_path).grep(/Finished parsing/).any?.should be_true
    end
  
    it "returns an array of parsed rows" do
      @parse_file_results.should have_at_least(1).items
      @parse_file_results[0].should be_an_instance_of QdsData
    end
  end

end