# encoding: utf-8
require_relative "../_processors/qds_csv_parser.rb"
require_relative "../_processors/model/qds_data.rb"

describe "QdsCsvParser" do
  before(:all) do
    @csv_parser = QdsCsvParser.new
    @log_file_path = "_processors/logs/QdsCsvParser.log"
    @sample_file_full_path = "_spec/test_data/test_qds_sample.csv"
    @sample_row = ["CQSpAA1RDel", "TOY", "TOY - Core", "Quarter 2 - 2012/13", "Current Quarter", "Spending Data", "Spend by Type of Budget", "Organisation's Own Budget (DEL)", "Resource (excl. depreciation)", "Actual", "105", "A note 1","","","","","","C1Large"]
    @sample_row_with_empty_data_sub_type = ["CQSpAA1RDel", "TOY", "TOY - Core", "Quarter 2 - 2012/13", "Current Quarter", "Spending Data", "Spend by Type of Budget", "Organisation's Own Budget (DEL)", "", "Actual", "105", "A note 1","","","","","","C1Large"]
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

  describe "#filter_row" do
    it "return false for valid row" do
      @csv_parser.filter_row(@sample_row).should be_false
    end

    it "returns true for rows with no value" do
      no_value_row = @sample_row.clone
      no_value_row[QdsCsvParser::VALUE_ROW_INDEX] = ""
      @csv_parser.filter_row(no_value_row).should be_true
    end

    it "returns true for rows with zero value" do
      zero_value_row = @sample_row.clone
      zero_value_row[QdsCsvParser::VALUE_ROW_INDEX] = "0"
      @csv_parser.filter_row(zero_value_row).should be_true
    end

    it "returns true for rows with Scope not core" do
      not_core_row = @sample_row.clone
      not_core_row[QdsCsvParser::SCOPE_ROW_INDEX] = "DVLA"
      @csv_parser.filter_row(not_core_row).should be_true
    end

    it "returns true for rows with Return Period not 'Current Quarter'" do
      not_current_quarter_row1 = @sample_row.clone
      not_current_quarter_row1[QdsCsvParser::RETURN_PERIOD_ROW_INDEX] = "Year To Date"

      not_current_quarter_row2 = @sample_row.clone
      not_current_quarter_row2[QdsCsvParser::RETURN_PERIOD_ROW_INDEX] = "Full Year Forecast"

      @csv_parser.filter_row(not_current_quarter_row1).should be_true
      @csv_parser.filter_row(not_current_quarter_row2).should be_true
    end

    it "return true for rows with Main Data Type not 'Spending Data'" do
      not_spending_data_row = @sample_row.clone
      not_spending_data_row[QdsCsvParser::MAIN_DATA_TYPE_ROW_INDEX] = "Performance Indicators"

      @csv_parser.filter_row(not_spending_data_row).should be_true
    end

    it "return true for rows with Data Period not 'Actual'" do
      not_actual_row = @sample_row.clone
      not_actual_row[QdsCsvParser::DATA_PERIOD_ROW_INDEX] = "Target"

      @csv_parser.filter_row(not_actual_row).should be_true
    end

  end

  describe "#parse_row" do
    context "sample row" do
      before(:all) do
        @parse_row_result = @csv_parser.parse_row(@sample_row)
      end

      it "raises ArgumentError if row has less than 12 rows" do
        expect {
            @csv_parser.parse_row((1..17).to_a.collect{ |i| i.to_s })
        }.to raise_error(ArgumentError)
      end

      it "returns a qds_data object" do
        @parse_row_result.should be_an_instance_of QdsData
      end

      it "returns object populated with values" do
        @parse_row_result.varname.should eq "CQSpAA1RDel"
        @parse_row_result.parent_department.should eq "TOY"
        @parse_row_result.scope.should eq "TOY - Core"
        @parse_row_result.report_date.should eq "Quarter 2 - 2012/13"
        @parse_row_result.section.should eq "Spend by Type of Budget"
        @parse_row_result.data_headline.should eq "Organisation's Own Budget (DEL)"
        @parse_row_result.data_sub_type.should eq "Resource (excl. depreciation)"
        @parse_row_result.metricName.should eq "C1Large"
      end

      it "returns value scaled to millions" do
        @parse_row_result.value.should eq 105 * 1000000.0
      end
    end
    context "a sample row with empty sub type" do
      it "returns a qds_data object using varname in place of sub type" do
        @csv_parser.parse_row(@sample_row_with_empty_data_sub_type).data_sub_type.should eq "CQSpAA1RDel"
      end
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
      @parse_file_results.should have(4).items
      @parse_file_results[0].should be_an_instance_of QdsData
    end
  end

end