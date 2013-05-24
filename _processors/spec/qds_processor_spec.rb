# encoding: utf-8
require_relative "../qds_processor.rb"

describe "QdsProcessor" do
	before(:each) do
		@processor = QdsProcessor.new
	end

	it "#new" do
		@processor.should be_an_instance_of QdsProcessor
	end

  describe "csv_parser" do
    it "should return a QdsCsvParser" do
      @processor.csv_parser.should be_an_instance_of QdsCsvParser
    end
  end

  describe "page_generator" do
    it "should return a TablePageGenerator with qds path" do
      @processor.page_generator.should be_an_instance_of TablePageGenerator
      @processor.page_generator.root_directory_path.should eq "qds"
    end
  end
end