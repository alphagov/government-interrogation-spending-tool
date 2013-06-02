# encoding: utf-8
require_relative "../_processors/qds_processor.rb"

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
    it "should return a TablePageGenerator with qds path and source label" do
      @processor.page_generator.should be_an_instance_of TablePageGenerator
      @processor.page_generator.root_directory_path.should eq "qds"
      @processor.page_generator.source_label.should eq "QDS"
    end
  end

  describe "root_node_options" do
    context "qds data for a single quarter, one department" do
      it "should return options with the quarter in quarters_list" do
        data_objects = get_qds_data_objects("Quarter 2 - 2012/13", 1, 1, 1, 1)

        options = @processor.root_node_options(data_objects)
        options.has_key?(:available_quarters).should be_true
        options[:available_quarters].length.should eq 1
        options[:available_quarters][0].should eq({ :title => "Quarter 2 2012", :slug => "q2-2012" })
      end
    end
    context "qds data for a two quarters, one department" do
      it "should return options with the quarter in quarters_list" do

        data_objects = get_qds_data_objects("Quarter 1 - 2012/13", 1, 1, 2, 2)
        data_objects = data_objects + get_qds_data_objects("Quarter 2 - 2012/13", 1, 1, 2, 2)

        options = @processor.root_node_options(data_objects)
        options.has_key?(:available_quarters).should be_true
        options[:available_quarters].length.should eq 2
        options[:available_quarters][0].should eq({ :title => "Quarter 1 2012", :slug => "q1-2012" })
        options[:available_quarters][1].should eq({ :title => "Quarter 2 2012", :slug => "q2-2012" })
      end
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

      it "should have a child node for quarter with generic quarter title and slug, alternative title" do
        @root_node.children[0].is_quarter.should be_true
        @root_node.children[0].slug.should eq "q2-2012"
        @root_node.children[0].title.should eq "Quarter 2 2012"
        @root_node.children[0].alternative_title_or_title.should eq "All Departments"
      end
      it "should have a child node for department" do
        @root_node.children[0].children[0].is_department.should be_true
        @root_node.children[0].children[0].alternative_title_or_title.should eq ""
      end
    end
  end

  describe "process" do

    TEST_QDS_PAGE_PATH = "_spec/test_pages"

    class TestQdsProcessor < QdsProcessor
      def page_generator
        TablePageGenerator.new(TEST_QDS_PAGE_PATH, "QDS 2012, date:15.01.12")
      end
    end

    before(:each) do
      @test_processor = TestQdsProcessor.new
    end

    context "test_qds_sample.csv" do
      it "should have generated the structure for the sample file" do
        @test_processor.process("_spec/test_data/test_qds_sample.csv")

        File.exists?("#{TEST_QDS_PAGE_PATH}/q2-2012/index.html").should be_true
        File.exists?("#{TEST_QDS_PAGE_PATH}/q2-2012/toy/index.html").should be_true
        File.exists?("#{TEST_QDS_PAGE_PATH}/q2-2012/toy/spend-by-budget-type/index.html").should be_true
        File.exists?("#{TEST_QDS_PAGE_PATH}/q2-2012/toy/spend-by-budget-type/organisations-own-budget-del/index.html").should be_true
      end
    end
    context "test_qds.csv" do
      it "should have generated the structure for the sample file" do
        @test_processor.process("_spec/test_data/test_qds.csv")

        File.exists?("#{TEST_QDS_PAGE_PATH}/q2-2012/index.html").should be_true
        File.exists?("#{TEST_QDS_PAGE_PATH}/q2-2012/toy/index.html").should be_true
        File.exists?("#{TEST_QDS_PAGE_PATH}/q2-2012/yot/index.html").should be_true

        File.exists?("#{TEST_QDS_PAGE_PATH}/q1-2012/index.html").should be_true
        File.exists?("#{TEST_QDS_PAGE_PATH}/q1-2012/toy/index.html").should be_true
        File.exists?("#{TEST_QDS_PAGE_PATH}/q1-2012/yot/index.html").should be_true
      end
    end

    after(:each) do
       FileUtils.rm_rf Dir.glob("#{TEST_QDS_PAGE_PATH}/*"), :secure => true
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