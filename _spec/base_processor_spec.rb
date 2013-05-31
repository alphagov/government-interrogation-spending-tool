# encoding: utf-8
require_relative "../_processors/base_processor.rb"

describe "BaseProcessor" do
	before(:each) do
		@processor = BaseProcessor.new
	end

	it "#new" do
		@processor.should be_an_instance_of BaseProcessor
	end

  describe "root_node_options" do
    it "should return an empty hash" do
      @processor.root_node_options.should eq({})
    end
  end

  describe "process" do
    before(:each) do
      @path = "test/path/raw_data.csv"

      @data_objects = ["1","2"]
      @csv_parser = double()
      @csv_parser.stub(:parse_file).and_return(@data_objects)

      @page_generator = double()
      @page_generator.stub(:generate_from_root_node)

      @processor.stub(:csv_parser).and_return(@csv_parser)
      @processor.stub(:page_generator).and_return(@page_generator)

      @root_node = "root"
      @processor.stub(:generate_root_node).and_return(@root_node)
    end
    it "should call the helper objects and methods to process the raw csv" do
      @csv_parser.should_receive(:parse_file).with(@path).once.ordered
      @processor.should_receive(:generate_root_node).with(@data_objects).once.ordered
      @processor.should_receive(:root_node_options).with(@data_objects).and_return({})
      @page_generator.should_receive(:generate_from_root_node).with(@root_node, {}).once.ordered

      @processor.process(@path)
    end
  end
end