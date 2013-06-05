# encoding: utf-8
require_relative "csv_parser.rb"
require_relative "model/qds_data.rb"

class QdsCsvParser < CsvParser

  VARNAME_ROW_INDEX           = 0
  PARENT_DEPARTMENT_ROW_INDEX = 1
  SCOPE_ROW_INDEX             = 2
  REPORT_DATE_ROW_INDEX       = 3
  RETURN_PERIOD_ROW_INDEX     = 4
  MAIN_DATA_TYPE_ROW_INDEX    = 5
  SECTION_ROW_INDEX           = 6
  DATA_HEADLINE_ROW_INDEX     = 7
  DATA_SUB_TYPE_ROW_INDEX     = 8
  DATA_PERIOD_ROW_INDEX       = 9
  VALUE_ROW_INDEX             = 10

  def log_file_path
    "_processors/logs/QdsCsvParser.log"
  end

  def filter_row(row)
    # Value must be set
    return true if is_numeric_string_empty_or_zero(row[VALUE_ROW_INDEX])
    # Scope must be 'Core'
    return true if !row[SCOPE_ROW_INDEX].downcase.include? 'core'
    # Return period must be 'Current Quarter'
    return true if !row[RETURN_PERIOD_ROW_INDEX].downcase.include? 'current quarter'
    # Main Data Type  must be 'Spending Data'
    return true if !row[MAIN_DATA_TYPE_ROW_INDEX].downcase.include? 'spending data'
    # Data Headline must not be 'Top Total'
    return true if row[DATA_HEADLINE_ROW_INDEX].downcase.include? 'top total'
    # Data Headline must not be 'Total Spend'
    return true if row[DATA_HEADLINE_ROW_INDEX].downcase.include? 'total spend'
    # Data Sub Type must not contain 'Sub-Total'
    return true if row[DATA_SUB_TYPE_ROW_INDEX].downcase.include? 'sub-total'
    # Data Period  must be 'Actual'
    return true if !row[DATA_PERIOD_ROW_INDEX].downcase.include? 'actual'

    false
  end

	def parse_row(row)
    raise ArgumentError, "Too few rows", caller if row.length < 12

    value = parse_value(row[VALUE_ROW_INDEX])
    value_scaled_to_millions = value * 1000000.0

    QdsData.new(
      row[PARENT_DEPARTMENT_ROW_INDEX],
      row[SCOPE_ROW_INDEX],
      row[REPORT_DATE_ROW_INDEX],
      row[SECTION_ROW_INDEX],
      row[DATA_HEADLINE_ROW_INDEX],
      row[DATA_SUB_TYPE_ROW_INDEX],
      value_scaled_to_millions)
	end

end