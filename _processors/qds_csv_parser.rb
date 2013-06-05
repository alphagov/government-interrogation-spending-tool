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

  METRICNAME_ROW_INDEX        = 17

  PROCUREMENT_COSTS = "procurement costs"
  PROCUREMENT_OF_WHICH_MAJOR_COMPONENT_CATEGORIES_METRICNAMES =[
    "C1CCL",
    "C1Cons",
    "C1MaM",
    "C1Goods",
    "C1Large",
    "C1CatOth"
  ]

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
    # Data Period  must be 'Actual'
    return true if !row[DATA_PERIOD_ROW_INDEX].downcase.include? 'actual'
    # Filter if Data Headline is 'Procurement Costs' and MetricName is not in list of Major Component categories
    return true if row[DATA_HEADLINE_ROW_INDEX].downcase.include?(PROCUREMENT_COSTS) &&
      !PROCUREMENT_OF_WHICH_MAJOR_COMPONENT_CATEGORIES_METRICNAMES.include?(row[METRICNAME_ROW_INDEX])

    false
  end

	def parse_row(row)
    raise ArgumentError, "Too few rows", caller if row.length < 18

    value = parse_value(row[VALUE_ROW_INDEX])
    value_scaled_to_millions = value * 1000000.0

    QdsData.new(
      row[VARNAME_ROW_INDEX],
      row[PARENT_DEPARTMENT_ROW_INDEX],
      row[SCOPE_ROW_INDEX],
      row[REPORT_DATE_ROW_INDEX],
      row[SECTION_ROW_INDEX],
      row[DATA_HEADLINE_ROW_INDEX],
      row[DATA_SUB_TYPE_ROW_INDEX],
      value_scaled_to_millions,
      row[METRICNAME_ROW_INDEX])
	end

end