# encoding: utf-8
require_relative "csv_parser.rb"
require_relative "model/qds_data.rb"

class QdsCsvParser < CsvParser

  def log_file_path
    "_processors/logs/QdsCsvParser.log"
  end

  def filter_row(row)
    # Value  must be set
    return true if row[9].empty?
    # Scope must be 'Core'
    return true if !row[1].downcase.include? 'core'
    # Return period must be 'Current Quarter'
    return true if !row[3].downcase.include? 'current quarter'
    # Main Data Type  must be 'Spending Data'
    return true if !row[4].downcase.include? 'spending data'
    # Data Period  must be 'Actual'
    return true if !row[8].downcase.include? 'actual'

    false
  end

	def parse_row(row)
    raise ArgumentError, "Too few rows", caller if row.length < 11

    QdsData.new(
      row[0],
      row[2],
      row[5],
      row[6],
      row[7],
      parse_value(row[9]))
	end

end