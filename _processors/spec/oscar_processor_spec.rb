# encoding: utf-8
require_relative "../oscar_processor.rb"

describe "OscarProcessor" do
	before(:each) do
		@processor = OscarProcessor.new
	end

	it "#new" do
		@processor.should be_an_instance_of OscarProcessor
	end

  describe "csv_parser" do
    it "should return a OscarCsvParser" do
      @processor.csv_parser.should be_an_instance_of OscarCsvParser
    end
  end

  describe "page_generator" do
    it "should return a TablePageGenerator with oscar path" do
      @processor.page_generator.should be_an_instance_of TablePageGenerator
      @processor.page_generator.root_directory_path.should eq "oscar"
    end
  end
end