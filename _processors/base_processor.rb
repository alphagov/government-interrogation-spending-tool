# encoding: utf-8
require_relative "csv_parser.rb"

class BaseProcessor

  def initialize
    @csv_parser = CsvParser.new
  end

  def csv_parser
    @csv_parser
  end

	def process(filename)
    puts "processing file: #{filename}"
	end
end