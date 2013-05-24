# encoding: utf-8
require_relative "../qds_processor.rb"

describe "QdsProcessor" do

	before(:all) do
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

  describe "generate_root_node" do
    context "qds data for a single quarter, one department, one section, one headline" do
      before(:all) do
        @data_objects = get_qds_data_objects("Quarter 2 - 2012/13", 1, 1, 2, 2)
        @root_node = @processor.generate_root_node(@data_objects)
      end

      it "should be a TablePageNode" do
        @root_node.should be_an_instance_of TablePageNode
      end

      it "should create a node tree with depth 4 with nodes: root, quarter, department, section, headline" do
        @root_node.children.should have(1).items
        @root_node.children[0].children.should have(1).items
        @root_node.children[0].children[0].children.should have(1).items
      end

    end
  end

  describe "process" do
    context "test_qds_sample.csv" do
      it "should have generated the structure for the sample file" do
        @processor.process("_processors/spec/test_data/test_qds_sample.csv")

        File.exists?("qds/quarter-2-2012-13/index.html").should be_true
        File.exists?("qds/quarter-2-2012-13/toy/index.html").should be_true
        File.exists?("qds/quarter-2-2012-13/toy/spend-by-budget-type/index.html").should be_true
        File.exists?("qds/quarter-2-2012-13/toy/spend-by-budget-type/organisations-own-budget-del/index.html").should be_true
      end
    end
    context "test_qds.csv" do
      it "should have generated the structure for the sample file" do
        @processor.process("_processors/spec/test_data/test_qds.csv")

        File.exists?("qds/quarter-2-2012-13/index.html").should be_true
        File.exists?("qds/quarter-2-2012-13/toy/index.html").should be_true
        File.exists?("qds/quarter-2-2012-13/yot/index.html").should be_true

        File.exists?("qds/quarter-1-2012-13/index.html").should be_true
        File.exists?("qds/quarter-1-2012-13/toy/index.html").should be_true
        File.exists?("qds/quarter-1-2012-13/yot/index.html").should be_true
      end
    end

    after(:each) do
       FileUtils.rm_rf Dir.glob("qds/*"), :secure => true
    end
  end

  def get_qds_data_objects(report_date, num_of_parent_departments, num_of_sections, num_of_data_headlines, num_of_data_sub_types)
    data_objects = []

    for d in 1..num_of_parent_departments
      for s in 1..num_of_sections
        for h in 1..num_of_data_headlines
          for t in 1..num_of_data_sub_types
            data_objects << QdsData.new(
              "DEP" + d.to_s,
              report_date,
              "Section " + s.to_s,
              "Data Headline " + h.to_s,
              "Data Sub Type " + t.to_s,
              t.to_f)
          end
        end
      end
    end

    data_objects
  end
end