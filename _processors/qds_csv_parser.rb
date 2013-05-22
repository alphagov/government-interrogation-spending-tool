# encoding: utf-8
require_relative "csv_parser.rb"
require_relative "model/qds_data.rb"

class QdsCsvParser < CsvParser

  def log_file_path
    "_processors/logs/QdsCsvParser.log"
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