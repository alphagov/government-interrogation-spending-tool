# encoding: utf-8
require_relative "../oscar_processor.rb"

describe "OscarProcessor" do
	before(:each) do
		@processor = OscarProcessor.new
	end

	it "#new" do
		@processor.should be_an_instance_of OscarProcessor
	end
end