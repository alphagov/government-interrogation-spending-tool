# encoding: utf-8
require_relative "base_processor.rb"
require_relative "oscar_csv_parser.rb"

class OscarProcessor < BaseProcessor
  def initialize
    @csv_parser = OscarCsvParser.new
  end
end