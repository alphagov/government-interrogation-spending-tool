# encoding: utf-8
require_relative "base_processor.rb"
require_relative "oscar_csv_parser.rb"
require_relative "table_page_generator.rb"

class OscarProcessor < BaseProcessor

  def csv_parser
    OscarCsvParser.new
  end

  def page_generator
    TablePageGenerator.new("oscar")
  end

end