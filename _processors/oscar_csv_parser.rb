# encoding: utf-8
require_relative "csv_parser.rb"
require_relative "model/oscar_data.rb"

class OscarCsvParser < CsvParser

  def log_file_path
    "_processors/logs/OscarCsvParser.log"
  end

  def filter_row(row)
    # Value must be set
    return true if is_numeric_string_empty_or_zero(row[16])

    false
  end

  def parse_row(row)
    raise ArgumentError, "Too few rows", caller if row.length < 17

    OscarData.new(
      row[1],
      row[2],
      row[4],
      row[8],
      row[14],
      row[15],
      parse_value(row[16]))
  end

end