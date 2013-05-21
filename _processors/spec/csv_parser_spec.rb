# encoding: utf-8
require_relative "../csv_parser.rb"

describe "CsvParser" do
  before(:all) do
    @csv_parser = CsvParser.new
    @sample_file_full_path = "_processors/spec/test_data/generic_sample.csv"
  end

  describe "#new" do
    it "takes no parameters and returns a CsvParser object" do
      @csv_parser.should be_an_instance_of CsvParser
    end
  end
  
  describe "#parse_row" do
    it "takes a row object and returns a string" do
      @csv_parser.parse_row(['1','2']).should eq "1,2"
    end
  end

  describe "#parse_file" do
    before(:all) do
      @log_file_path = "_processors/logs/CsvParser.log"
      @parse_file_results = @csv_parser.parse_file(@sample_file_full_path)
    end 
  
    it "creates a log file containing logging messages" do
      File.exist?(@log_file_path).should be_true
      File.readlines(@log_file_path).grep(/Finished parsing/).any?.should be_true
    end
  
    it "returns an array of parsed rows" do
      @parse_file_results.length.should eq 3
      @parse_file_results[0].should eq "11,12,13"
    end
  end

end