# encoding: utf-8
require_relative "csv_parser.rb"
require_relative "model/qds_data.rb"

class QdsCsvParser < CsvParser

  def log_file_path
    "_processors/logs/QdsCsvParser.log"
  end

  def filter_row(row)
    # Value must be set
    return true if is_numeric_string_empty_or_zero(row[9])
    # Scope must be 'Core'
    return true if !row[1].downcase.include? 'core'
    # Return period must be 'Current Quarter'
    return true if !row[3].downcase.include? 'current quarter'
    # Main Data Type  must be 'Spending Data'
    return true if !row[4].downcase.include? 'spending data'
    # Data Headline must not be 'Top Total'
    return true if row[6].downcase.include? 'top total'
    # Data Headline must not be 'Total Spend'
    return true if row[6].downcase.include? 'total spend'
    # Data Sub Type must not contain 'Sub-Total'
    return true if row[7].downcase.include? 'sub-total'
    # Data Period  must be 'Actual'
    return true if !row[8].downcase.include? 'actual'

    false
  end

	def parse_row(row)
    raise ArgumentError, "Too few rows", caller if row.length < 11

    value = parse_value(row[9])
    value_scaled_to_millions = value * 1000000.0

    QdsData.new(
      row[0],
      row[2],
      row[5],
      row[6],
      row[7],
      value_scaled_to_millions)
	end

end