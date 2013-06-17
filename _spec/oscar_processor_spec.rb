# encoding: utf-8
require_relative "../_processors/oscar_processor.rb"
require_relative "../_processors/model/oscar_data.rb"

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
    it "should return a TablePageGenerator with oscar path and source label" do
      @processor.page_generator.should be_an_instance_of TablePageGenerator
      @processor.page_generator.root_directory_path.should eq "oscar"
      @processor.page_generator.source_label.should eq "OSCAR"
    end
  end

  describe "root_node_options" do
    context "oscar data for a single quarter" do
      before :each do
        quarter = "Qtr2 - 12-13"
        data_objects = get_oscar_data_objects([quarter], ["1"], ["2"], ["3"], ["4"])
        @options = @processor.root_node_options(data_objects)
      end
      it "should return options with option to format number in thousands" do
        @options.has_key?(:number_formatter_scale).should be_true
        @options[:number_formatter_scale].should eq "k"
      end
      it "should return options with the quarter in quarters_list" do
        @options.has_key?(:available_quarters).should be_true
        @options[:available_quarters].length.should eq 1
        @options[:available_quarters][0].should eq({ :title => "Quarter 2 2012-13", :slug => "q2-2012-13" })
      end
    end
    context "oscar data for a two quarters" do
      it "should return options with the quarter in quarters_list" do
        quarter1 = "Qtr1 - 12-13"
        quarter2 = "Qtr2 - 12-13"
        data_objects = get_oscar_data_objects([quarter1, quarter2], ["1"], ["2"], ["3"], ["4"])

        options = @processor.root_node_options(data_objects)
        options.has_key?(:available_quarters).should be_true
        options[:available_quarters].length.should eq 2
        options[:available_quarters][0].should eq({ :title => "Quarter 1 2012-13", :slug => "q1-2012-13" })
        options[:available_quarters][1].should eq({ :title => "Quarter 2 2012-13", :slug => "q2-2012-13" })
      end
    end
  end

  describe "generate_root_node" do
    context "oscar data for a single quarter, one department, one organisation, one control code, 2 Economic Category Long Names with 3 months data each" do
      before(:each) do
        @quarter = "Qtr2 - 12-13"
        @segment_department_long_name = "Test Office"
        @organisation = "TEST OFFICE"
        @control_budget_code = "DEL"
        @economic_category_long_names = ["PAY","RENTAL COSTS"]

        data_objects = get_oscar_data_objects([@quarter], [@segment_department_long_name], [@organisation], [@control_budget_code], @economic_category_long_names)
        @root_node = @processor.generate_root_node(data_objects)
      end

      it "should be a TablePageNode" do
        @root_node.should be_an_instance_of TablePageNode
      end

      it "the root node should use the alternative layout table_root" do
        @root_node.alternative_layout.should eq "table_root"
      end

      it "the root node should use table header label Quarter" do
        @root_node.table_header_name_label.should eq "Quarter"
      end

      it "should create a node tree with a single node for quarter, department, org, control code, the 2 econ category names" do
        @root_node.children.should have(1).items
        @root_node.children[0].children.should have(1).items
        @root_node.children[0].children[0].children.should have(1).items
        @root_node.children[0].children[0].children[0].children.should have(1).items
        @root_node.children[0].children[0].children[0].children[0].children.should have(2).items
      end
      it "should have a child node for quarter with generic quarter slug and title, alternative title, table header name label" do
        @root_node.children[0].is_quarter.should be_true
        @root_node.children[0].slug.should eq "q2-2012-13"
        @root_node.children[0].title.should eq "Quarter 2 2012-13"
        @root_node.children[0].alternative_title_or_title.should eq "All Departments"
        @root_node.children[0].table_header_name_label.should eq "Department"
      end
      it "should have a child node for department" do
        @root_node.children[0].children[0].is_department.should be_true
        @root_node.children[0].children[0].alternative_title_or_title.should eq ""
        @root_node.children[0].children[0].table_header_name_label.should eq "Department/Organisation"
      end
      it "control code nodes should have display_foi set to true" do
        @root_node.children[0].children[0].children[0].children[0].display_foi.should be_true
      end
    end
  end

  describe "process" do

    TEST_PAGE_PATH = "_spec/test_pages"

    class TestOscarProcessor < OscarProcessor
      def page_generator
        TablePageGenerator.new(TEST_PAGE_PATH, "OSCAR 2012, date:15.01.12")
      end
    end

    before(:each) do
      @test_processor = TestOscarProcessor.new
    end
    context "test_oscar_sample.csv" do
      it "should have generated the structure for the sample file" do
        @test_processor.process("_spec/test_data/test_oscar_sample.csv")

        File.exists?("#{TEST_PAGE_PATH}/index.html").should be_true
        File.exists?("#{TEST_PAGE_PATH}/q2-2012-13/index.html").should be_true
      end
    end

    context "test_oscar.csv" do
      it "should have generated the structure for the sample file" do
        @test_processor.process("_spec/test_data/test_oscar.csv")

        File.exists?("#{TEST_PAGE_PATH}/index.html").should be_true
        File.exists?("#{TEST_PAGE_PATH}/q2-2012-13/index.html").should be_true
      end
    end

    after(:each) do
      FileUtils.rm_rf Dir.glob("#{TEST_PAGE_PATH}/*"), :secure => true
    end
  end

  def get_oscar_data_objects(quarters,
    segment_department_long_names,
    organisations,
    control_budget_codes,
    economic_category_long_names)
    data_objects = []

    quarters.each do |quarter|
      segment_department_long_names.each do |segment_department_long_name|
        organisations.each do |organisation|
          control_budget_codes.each do |control_budget_code|
            economic_category_long_names.each do |economic_category_long_name|
              ["Jul-12", "Aug-12", "Sep-12"].each do |month|
                data_objects << OscarData.new(
                  organisation,
                  control_budget_code,
                  segment_department_long_name,
                  economic_category_long_name,
                  quarter,
                  month,
                  10.0
                )
              end
            end
          end
        end
      end
    end

    data_objects
  end

end