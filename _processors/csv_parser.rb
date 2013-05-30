# encoding: utf-8
require 'csv'
require 'date'
require "logger"
require "fileutils"

class CsvParser

  def log_file_path
    "_processors/logs/CsvParser.log"
  end

  def parse_value(numeric_string)
    Float(numeric_string.gsub(',',''))
  end

  def filter_row(row)
    false
  end

  def is_numeric_string_empty_or_zero(numeric_string)
    return true if numeric_string.empty?
    return true if parse_value(numeric_string) == 0.0

    false
  end

  def parse_row(row)
    row.join(",")
  end

  def parse_file(file_full_path)
    FileUtils.rm(log_file_path) if File.exists?(log_file_path)
    log = Logger.new(log_file_path)
    log.level = Logger::DEBUG

    raise ArgumentError, "File does not exist", caller if !File.exists?(file_full_path)

    filler = nil
    row_index = 0
    parsed_count = 0
    parsed_rows = []
    CSV.foreach(file_full_path, { :encoding => "iso-8859-1:utf-8" }) do |row|
      begin
        if row_index > 0
          parsed_rows << parse_row(row) if !filter_row(row)
          parsed_count += 1
        end
      rescue Exception => e
        log.info "INVALID ROW: #{row_index} - #{row.to_s} - #{e.message}"
      end

      if row_index % 100 == 0 && row_index > 0
        log.info "Parsed #{row_index} rows"
      end
      row_index += 1
    end
    log.info "Finished parsing: parsed #{parsed_count} rows"

    parsed_rows
  end

end