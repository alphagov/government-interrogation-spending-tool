# encoding: utf-8
require_relative "../oscar_csv_parser.rb"
require_relative "../model/oscar_data.rb"

describe "OscarCsvParser" do
  before(:all) do
    @csv_parser = OscarCsvParser.new
    @log_file_path = "_processors/logs/OscarCsvParser.log"
    @sample_file_full_path = "_processors/spec/test_data/test_oscar_sample.csv"
    @sample_row = [
      "TST010",
      "TEST OFFICE",
      "DEL",
      "DEL ADMIN",
      "Test Office",
      "X010CR01",
      "X010CR01-POLITICAL AND CONSTITUTIONAL REFORM VOTED DEL ADMIN",
      "A101",
      "PAY",
      "RESOURCE",
      "STAFF COSTS",
      "Staff costs",
      "RETURN10_FEB",
      "2012-13",
      "Qtr3 - 12-13",
      "Dec-12",
      "275"]
  end

  describe "#new" do
    it "takes no parameters and returns a OscarCsvParser object" do
      @csv_parser.should be_an_instance_of OscarCsvParser
    end
  end

  describe "#log_file_path" do
    it "returns the log file path" do
      @csv_parser.log_file_path.should eq @log_file_path
    end
  end

  describe "#filter_row" do
    it "return false for valid row" do
      @csv_parser.filter_row(@sample_row).should be_false
    end

    it "returns true for rows with no value" do
      no_value_row = @sample_row.clone
      no_value_row[16] = ""
      @csv_parser.filter_row(no_value_row).should be_true
    end

    it "returns true for rows with zero value" do
      zero_value_row = @sample_row.clone
      zero_value_row[16] = "0"
      @csv_parser.filter_row(zero_value_row).should be_true
    end
  end

  describe "#parse_row" do
    before(:all) do
      @parse_row_result = @csv_parser.parse_row(@sample_row)
    end

    it "raises ArgumentError if row has less than 17 rows" do
      expect {
          @csv_parser.parse_row((1..16).to_a.collect{ |i| i.to_s })
      }.to raise_error(ArgumentError)
    end

    it "returns a oscar_data object" do
      @parse_row_result.should be_an_instance_of OscarData
    end

    it "object populated with values" do
      @parse_row_result.organisation.should eq "TEST OFFICE"
      @parse_row_result.control_budget_code.should eq "DEL"
      @parse_row_result.segment_department_long_name.should eq "Test Office"
      @parse_row_result.economic_category_long_name.should eq "PAY"
      @parse_row_result.quarter.should eq "Qtr3 - 12-13"
      @parse_row_result.month.should eq "Dec-12"
      @parse_row_result.amount.should eq 275
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
      @parse_file_results.should have(16).items
      @parse_file_results[0].should be_an_instance_of OscarData
    end
  end

end