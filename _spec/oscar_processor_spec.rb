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
    it "should return a TablePageGenerator with oscar path" do
      @processor.page_generator.should be_an_instance_of TablePageGenerator
      @processor.page_generator.root_directory_path.should eq "oscar"
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

      it "should create a node tree with a single node for quarter, department, org, control code, the 2 econ category names" do
        @root_node.children.should have(1).items
        @root_node.children[0].children.should have(1).items
        @root_node.children[0].children[0].children.should have(1).items
        @root_node.children[0].children[0].children[0].children.should have(1).items
        @root_node.children[0].children[0].children[0].children[0].children.should have(2).items
      end
      it "should have a child node for quarter with generic quarter slug and title" do
        @root_node.children[0].slug.should eq "q2-2012"
        @root_node.children[0].title.should eq "Quarter 2 2012"
      end
    end
  end

  describe "process" do
    context "test_oscar_sample.csv" do
      it "should have generated the structure for the sample file" do
        @processor.process("_spec/test_data/test_oscar_sample.csv")

        File.exists?("oscar/index.html").should be_true
        File.exists?("oscar/q2-2012/index.html").should be_true
      end
    end

    context "test_oscar.csv" do
      it "should have generated the structure for the sample file" do
        @processor.process("_spec/test_data/test_oscar.csv")

        File.exists?("oscar/index.html").should be_true
        File.exists?("oscar/q2-2012/index.html").should be_true
      end
    end

    after(:each) do
      FileUtils.rm_rf Dir.glob("oscar/*"), :secure => true
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