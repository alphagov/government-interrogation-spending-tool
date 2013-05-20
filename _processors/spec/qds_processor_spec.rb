# encoding: utf-8
require_relative "../qds_processor.rb"

describe "QdsProcessor" do
	before(:each) do
		@processor = QdsProcessor.new
	end

	it "#new" do
		@processor.should be_an_instance_of QdsProcessor
	end
end