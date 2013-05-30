# encoding: utf-8
require_relative "../_processors/csv_parser.rb"

describe "CsvParser" do
  before(:all) do
    @csv_parser = CsvParser.new
    @log_file_path = "_processors/logs/CsvParser.log"
    @sample_file_full_path = "_spec/test_data/generic_sample.csv"
  end

  describe "#new" do
    it "takes no parameters and returns a CsvParser object" do
      @csv_parser.should be_an_instance_of CsvParser
    end
  end

  describe "#log_file_path" do
    it "returns the log file path" do
      @csv_parser.log_file_path.should eq @log_file_path
    end
  end

  describe "#parse_value" do
    it "takes a numeric_string and returns a float" do
      @csv_parser.parse_value("100.5").should eq 100.5
      @csv_parser.parse_value("9,999,999.9").should eq 9999999.9
    end
    it "should raise error on invalid numeric string" do
      expect { @csv_parser.parse_value("£100.5") }.to raise_error
      expect { @csv_parser.parse_value("NOT APPLICABLE") }.to raise_error
      expect { @csv_parser.parse_value("100.5 TOTAL") }.to raise_error
    end
  end

  describe "#is_numeric_string_empty_or_zero" do
    it "takes a numeric string and returns true if empty" do
      @csv_parser.is_numeric_string_empty_or_zero("").should be_true
    end

    it "takes a numeric_string and returns true if zero" do
      @csv_parser.is_numeric_string_empty_or_zero("0").should be_true
    end

    it "takes a numeric_string and returns false if non-zero" do
      @csv_parser.is_numeric_string_empty_or_zero("11.0").should be_false
    end
  end

  describe "#filter_row" do
    it "returns false" do
      @csv_parser.filter_row(["1"]).should be_false
    end
  end

  describe "#parse_row" do
    it "takes a row object and returns a string" do
      @csv_parser.parse_row(['1','2']).should eq "1,2"
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
      @parse_file_results.length.should eq 3
      @parse_file_results[0].should eq "11,12,13"
    end
  end

end