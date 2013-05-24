# encoding: utf-8
require_relative "base_processor.rb"
require_relative "qds_csv_parser.rb"
require_relative "table_page_generator.rb"

class QdsProcessor < BaseProcessor

  def csv_parser
    QdsCsvParser.new
  end

  def page_generator
    TablePageGenerator.new("qds")
  end

end