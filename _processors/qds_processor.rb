# encoding: utf-8
require_relative "base_processor.rb"
require_relative "qds_csv_parser.rb"

class QdsProcessor < BaseProcessor
  def initialize
    @csv_parser = QdsCsvParser.new
  end
end