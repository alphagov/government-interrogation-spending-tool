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
    context "qds data for a single quarter, one department, with one parent_department" do
      before :each do
        data_objects = get_qds_data_objects("Quarter 2 - 2012/13", ["DEP"], ["DEP - Core"], ["Spend by Type of Budget"], ["Organisation's Own Budget (DEL)"], ["Capital"])
        @options = @processor.root_node_options(data_objects)
      end

      it "should return options with option to format number in millions" do
        @options.has_key?(:number_formatter_scale).should be_true
        @options[:number_formatter_scale].should eq "m"
      end
      it "should return options with the quarter in quarters_list" do
        @options.has_key?(:available_quarters).should be_true
        @options[:available_quarters].length.should eq 1
        @options[:available_quarters][0].should eq({ :title => "Quarter 2 2012", :slug => "q2-2012" })
      end
    end
    context "qds data for a two quarters, one department, with one parent_department" do
      it "should return options with the quarter in quarters_list" do

        data_objects = get_qds_data_objects("Quarter 1 - 2012/13", ["DEP"], ["DEP - Core"], ["Spend by Type of Budget"], ["DEL1", "DEL2"], ["Capital1", "Capital2"])
        data_objects = data_objects + get_qds_data_objects("Quarter 2 - 2012/13", ["DEP"], ["DEP - Core"], ["Spend by Type of Budget"], ["DEL1", "DEL2"], ["Capital1", "Capital2"])

        options = @processor.root_node_options(data_objects)
        options.has_key?(:available_quarters).should be_true
        options[:available_quarters].length.should eq 2
        options[:available_quarters][0].should eq({ :title => "Quarter 1 2012", :slug => "q1-2012" })
        options[:available_quarters][1].should eq({ :title => "Quarter 2 2012", :slug => "q2-2012" })
      end
    end
  end

  describe "generate_root_node" do
    context "qds data for a single quarter, one department, one parent_department, one section, one headline" do
      before(:each) do
        @data_objects = get_qds_data_objects("Quarter 2 - 2012/13", ["DEP"], ["DEP - Core"], ["Spend by Type of Budget"], ["DEL1"], ["Capital1"])
        @root_node = @processor.generate_root_node(@data_objects)
      end

      it "should be a TablePageNode" do
        @root_node.should be_an_instance_of TablePageNode
      end

      it "the root node should used the alternative layout table_root" do
        @root_node.alternative_layout.should eq "table_root"
      end

      it "should create a node tree with depth 5 with nodes: root, quarter, scope abbr, parent_department, section, headline" do
        @root_node.children.should have(1).items

        @root_node.children[0].children.should have(1).items
        @root_node.children[0].children[0].children.should have(1).items
        @root_node.children[0].children[0].children[0].children.should have_at_least(1).items
        @root_node.children[0].children[0].children[0].children[0].children.should have_at_least(1).items
        @root_node.children[0].children[0].children[0].children[0].children[0].children.should have(1).items
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

      it "Data headline nodes should have display_foi set to true" do
        @root_node.children[0].children[0].children[0].children[0].children[0].display_foi.should be_true
      end

      it "should have redirect url set at parent_department level to redirect to spend-by-type-of-budget" do
        @root_node.children[0].children[0].children[0].redirect_url.should eq "/qds/q2-2012/dep/dep/spend-by-type-of-budget"
      end

      it "should use alternative_layout table_qds_section at the section level" do
        @root_node.children[0].children[0].children[0].children[0].alternative_layout.should eq "table_qds_section"
      end

      it "should use table header name label at root, quarter, department level" do
        @root_node.table_header_name_label.should eq "Quarter"
        @root_node.children[0].table_header_name_label.should eq "Department"
        @root_node.children[0].children[0].table_header_name_label.should eq "Department/Organisation"
      end

      it "should include nodes for all three QDS sections, with nodes using alternative_layout table_qds_section_nodata for sections with no data" do
        @root_node.children[0].children[0].children[0].children.should have(3).items
        section_nodes = @root_node.children[0].children[0].children[0].children
        no_data_layout = "table_qds_section_no_data"

        section_nodes.any? { |section_node| section_node.slug == "spend-by-type-of-budget" && section_node.alternative_layout == "table_qds_section" }.should be_true
        section_nodes.any? { |section_node| section_node.slug == "spend-by-type-of-internal-operation" && section_node.alternative_layout == no_data_layout }.should be_true
        section_nodes.any? { |section_node| section_node.slug == "spend-by-type-of-transaction" && section_node.alternative_layout == no_data_layout }.should be_true
      end
    end
    context "qds data for a single quarter, one scope abbr, two parent_departments, one section, one headline" do
      before(:each) do
        @data_objects = get_qds_data_objects("Quarter 2 - 2012/13", ["DECC", "NDA"], ["DECC - Core"], ["Spend by Type of Budget"], ["DEL1"], ["Capital1"])
        @root_node = @processor.generate_root_node(@data_objects)
      end

      it "should have a child node for quarter, one scope abbr with 2 child nodes for parent_departments" do
        @root_node.children.should have(1).items

        @root_node.children[0].children.should have(1).items
        @root_node.children[0].children[0].children.should have(2).items

        @root_node.children[0].children[0].children[0].title.should eq "DECC"
        @root_node.children[0].children[0].children[1].title.should eq "NDA"
      end
    end
    context "qds data for a single quarter, one scope abbr, one parent_departments, one section, one headline with a total row" do
      before(:each) do
        @sub_total = 1000.0
        @total_spend = 2000.0
        @top_total = 3000.0

        @data_objects = get_qds_data_objects("Quarter 2 - 2012/13", ["DECC"], ["DECC - Core"], ["Spend by Type of Budget"], ["Organisation's Own Budget (DEL)"], ["Capital"])
        @data_objects = @data_objects + get_qds_data_objects("Quarter 2 - 2012/13", ["DECC"], ["DECC - Core"], ["Spend by Type of Budget"], ["Organisation's Own Budget (DEL)"], ["Organisation's Own Budget (DEL), Sub-Total"], @sub_total, "CQSpAA1SubTot")
        @data_objects = @data_objects + get_qds_data_objects("Quarter 2 - 2012/13", ["DECC"], ["DECC - Core"], ["Spend by Type of Budget"], ["Total Spend"], ["Total Spend"], @total_spend, "CQSpAATot")
        @data_objects = @data_objects + get_qds_data_objects("Quarter 2 - 2012/13", ["DECC"], ["DECC - Core"], ["Spend by Type of Budget"], ["Top Total"], ["Top Total"], @top_total,"CQSpATot")

        @root_node = @processor.generate_root_node(@data_objects)
      end
      it "should not include total row in headline childs" do
        @root_node.children[0].children[0].children[0].children[0].children[0].children.should have(1).items
      end
      it "should not include total rows as children at each level" do
        @root_node.children[0].children[0].children[0].children[0].children.should have(1).items
      end
      it "should use the Top Total value as the Total at the parent_department level" do
        @root_node.children[0].children[0].children[0].total.should eq @top_total
      end
      it "should use the Total Spend value as the Total at the section level" do
        @root_node.children[0].children[0].children[0].children[0].total.should eq @total_spend
      end
      it "should use the Sub-Total value as the Total at the headline level" do
        @root_node.children[0].children[0].children[0].children[0].children[0].total.should eq @sub_total
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
        File.exists?("#{TEST_QDS_PAGE_PATH}/q2-2012/toy/toy/index.html").should be_true
        File.exists?("#{TEST_QDS_PAGE_PATH}/q2-2012/toy/toy/spend-by-type-of-budget/index.html").should be_true
        File.exists?("#{TEST_QDS_PAGE_PATH}/q2-2012/toy/toy/spend-by-type-of-budget/organisations-own-budget-del/index.html").should be_true
      end
    end
    context "test_qds.csv" do
      it "should have generated the structure for the sample file" do
        @test_processor.process("_spec/test_data/test_qds.csv")

        File.exists?("#{TEST_QDS_PAGE_PATH}/q2-2012/index.html").should be_true
        File.exists?("#{TEST_QDS_PAGE_PATH}/q2-2012/toy/index.html").should be_true
        File.exists?("#{TEST_QDS_PAGE_PATH}/q2-2012/toy/toy/index.html").should be_true
        File.exists?("#{TEST_QDS_PAGE_PATH}/q2-2012/yot/index.html").should be_true
        File.exists?("#{TEST_QDS_PAGE_PATH}/q2-2012/yot/yot/index.html").should be_true

        File.exists?("#{TEST_QDS_PAGE_PATH}/q1-2012/index.html").should be_true
        File.exists?("#{TEST_QDS_PAGE_PATH}/q1-2012/toy/index.html").should be_true
        File.exists?("#{TEST_QDS_PAGE_PATH}/q1-2012/toy/toy/index.html").should be_true
        File.exists?("#{TEST_QDS_PAGE_PATH}/q1-2012/yot/index.html").should be_true
        File.exists?("#{TEST_QDS_PAGE_PATH}/q1-2012/yot/yot/index.html").should be_true
      end
    end

    after(:each) do
       FileUtils.rm_rf Dir.glob("#{TEST_QDS_PAGE_PATH}/*"), :secure => true
    end
  end

  def get_qds_data_objects(report_date, parent_departments, scopes, sections, data_headlines, data_sub_types, value=10.0, varname = "CQSpAA1RDel")
    data_objects = []

    parent_departments.each do |parent_department|
      scopes.each do |scope|
        sections.each do |section|
          data_headlines.each do |data_headline|
            data_sub_types.each_with_index do |data_sub_type, t|
              data_objects << QdsData.new(
                varname,
                parent_department,
                scope,
                report_date,
                section,
                data_headline,
                data_sub_type,
                value,
                "C1Large")
            end
          end
        end
      end
    end

    data_objects
  end
end