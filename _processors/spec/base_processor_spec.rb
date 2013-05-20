# encoding: utf-8
require_relative "../base_processor.rb"

describe "BaseProcessor" do
	before(:each) do
		@processor = BaseProcessor.new
	end

	it "#new" do
		@processor.should be_an_instance_of BaseProcessor
	end
end