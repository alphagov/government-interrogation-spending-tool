# encoding: utf-8
require_relative "../_processors/table_page_generator.rb"
require_relative "../_processors/model/table_page_node.rb"

describe "TablePageGenerator" do
  before(:each) do
    @root_directory_path = "_spec/test_pages"
    @source_label = "PESA 2011, date:15.01.12"
    @page_generator = TablePageGenerator.new(@root_directory_path, @source_label)

    @child_node1 = TablePageNode.new("Toy", 100.0)
    @child_node2 = TablePageNode.new("Test", 200.0)
    @root_node = TablePageNode.new("All Departments", 300.0, [@child_node1, @child_node2], "")

    @empty_node = TablePageNode.new("Empty", 100.0)

    @leaf_node1 = TablePageNode.new("Toy 1", 100.0)
    @leaf_node2 = TablePageNode.new("Toy 2", 200.0)
    @child_node_not_empty = TablePageNode.new("Toy", 100.0, [@leaf_node1, @leaf_node2])
    @child_node_empty = TablePageNode.new("Empty", 200.0)
    @root_node_with_two_levels = TablePageNode.new("All Departments", 300.0, [@child_node_empty, @child_node_not_empty], "")

    @child_node_not_empty_redirect = TablePageNode.new("Toy", 100.0, [@leaf_node1, @leaf_node2], "toy", {:redirect_url => "/qds/q1-2012/toy/toy/spend-by-budget-type"})
  end

  describe "#new" do
    it "takes two parameters and returns a TablePageGenerator object" do
      @page_generator.should be_an_instance_of TablePageGenerator
    end
  end

  describe "#root_directory_path" do
    it "returns the root directory path" do
      @page_generator.root_directory_path.should eq @root_directory_path
    end
  end

  describe "#source_label" do
    it "returns the source label" do
      @page_generator.source_label.should eq @source_label
    end
  end

  describe "delete_existing_files" do
    before(:each) do
      @root_file = "#{@root_directory_path}/index.html"
      @root_dir_empty = "#{@root_directory_path}/2013-quarter-2"
      @root_dir_w_contents = "#{@root_directory_path}/2013-quarter-1"

      @dir_file = "#{@root_dir_w_contents}/index.html"
      @dir_dir_empty = "#{@root_dir_w_contents}/test"
      @dir_dir_w_contents = "#{@root_dir_w_contents}/toy"

      @dir_dir_file = "#{@dir_dir_w_contents}/index.html"

      File.open(@root_file, 'w') {|f| f.write("index") }
      Dir::mkdir(@root_dir_empty) unless File.exists?(@root_dir_empty)
      Dir::mkdir(@root_dir_w_contents) unless File.exists?(@root_dir_w_contents)

      File.open(@dir_file, 'w') {|f| f.write("index") }
      Dir::mkdir(@dir_dir_empty) unless File.exists?(@dir_dir_empty)
      Dir::mkdir(@dir_dir_w_contents) unless File.exists?(@dir_dir_w_contents)

      File.open(@dir_dir_file, 'w') {|f| f.write("index") }

      @page_generator.delete_existing_files
    end

    it "removes existing files and directories from the root directory" do
      File.exists?(@root_file).should be_false
      File.exists?(@root_dir_empty).should be_false
      File.exists?(@root_dir_w_contents).should be_false

      File.exists?(@dir_file).should be_false
      File.exists?(@dir_dir_empty).should be_false
      File.exists?(@dir_dir_w_contents).should be_false

      File.exists?(@dir_dir_file).should be_false
    end

    after :each do
      FileUtils.rm_rf Dir.glob("#{@root_directory_path}/*"), :secure => true
    end
  end

  describe "generate_for_node" do
    before :each do
      @test_content = "test"
      @test_csv_content = "test,value"
      @test_redirect_content = "redirect"

      @page_generator.stub(:generate_html_content).and_return(@test_content)
      @page_generator.stub(:generate_csv_content).and_return(@test_csv_content)
      @page_generator.stub(:generate_redirect_page_content).and_return(@test_redirect_content)
    end

    context "node with children" do
      it "creates an index.html, chart.png and data.csv file for the node containing test content" do
        @page_generator.should_receive(:generate_html_content).with(@root_node, {}).once
        @page_generator.should_receive(:generate_csv_content).with(@root_node, {}).once
        @page_generator.generate_for_node(@root_node)
        index_file = "#{@root_directory_path}/index.html"
        png_file   = "#{@root_directory_path}/chart.png"
        csv_file   = "#{@root_directory_path}/data.csv"

        File.exists?(index_file).should be_true
        File.exists?(png_file).should be_true
        File.exists?(csv_file).should be_true

        File.read(index_file).should eq (@test_content)
        File.read(csv_file).should eq (@test_csv_content)
      end
    end

    context "node with no children" do
      it "does not create an index.html, chart.png and data.csv file for the node" do
        @page_generator.generate_for_node(@empty_node)
        File.exists?("#{@root_directory_path}/empty/index.html").should be_false
        File.exists?("#{@root_directory_path}/empty/data.csv").should be_false
        File.exists?("#{@root_directory_path}/empty/chart.png").should be_false
      end
    end

    context "node under parent slug" do
      it "creates an index.html, chart.png and data.csv file under the parent slug directory" do
        @page_generator.generate_for_node(@root_node, { :parent_slug_list => [@root_directory_path, 'toy'] })
        File.exists?("#{@root_directory_path}/toy/index.html").should be_true
        File.exists?("#{@root_directory_path}/toy/data.csv").should be_true
        File.exists?("#{@root_directory_path}/toy/chart.png").should be_true
      end
      it "creates an index.html, chart.png and data.csv file under the parent slug directory and own slug" do
        @page_generator.generate_for_node(@child_node_not_empty, { :parent_slug_list => [@root_directory_path, 'test'] })
        File.exists?("#{@root_directory_path}/test/toy/index.html").should be_true
        File.exists?("#{@root_directory_path}/test/toy/data.csv").should be_true
        File.exists?("#{@root_directory_path}/test/toy/chart.png").should be_true
      end
    end

    context "node with redirect url" do
      it "creates an index.html with redirect url, no chart.png and data.csv file under the parent slug directory and own slug" do
        @page_generator.should_receive(:generate_redirect_page_content).once

        @page_generator.generate_for_node(@child_node_not_empty_redirect, { :parent_slug_list => [@root_directory_path, 'test'] })
        File.exists?("#{@root_directory_path}/test/toy/index.html").should be_true
        File.read("#{@root_directory_path}/test/toy/index.html").should eq (@test_redirect_content)

        File.exists?("#{@root_directory_path}/test/toy/data.csv").should be_false
        File.exists?("#{@root_directory_path}/test/toy/chart.png").should be_false
      end
    end

    after :each do
      FileUtils.rm_rf Dir.glob("#{@root_directory_path}/*"), :secure => true
    end
  end

  describe "generate_from_root_node" do
    context "root node with one empty and one non-empty child nodes" do
      before :each do
        @page_generator.stub(:delete_existing_files)
        @page_generator.stub(:generate_for_node)
      end

      it "calls delete_existing_files before generating" do
        @page_generator.should_receive(:delete_existing_files)

        @page_generator.generate_from_root_node(@root_node_with_two_levels)
      end

      it "calls generate_for_node for each node passing parent slug path and title" do
        @page_generator.should_receive(:generate_for_node).with(@root_node_with_two_levels, { :parent_slug_list => [@root_directory_path],        :parent_title_list => [@root_directory_path.upcase] }).once
        @page_generator.should_receive(:generate_for_node).with(@child_node_empty, {          :parent_slug_list => [@root_directory_path],        :parent_title_list => [@root_directory_path.upcase] }).once
        @page_generator.should_receive(:generate_for_node).with(@child_node_not_empty, {      :parent_slug_list => [@root_directory_path],        :parent_title_list => [@root_directory_path.upcase] }).once
        @page_generator.should_receive(:generate_for_node).with(@leaf_node1, {                :parent_slug_list => [@root_directory_path, "toy"], :parent_title_list => [@root_directory_path.upcase, "Toy"] }).once
        @page_generator.should_receive(:generate_for_node).with(@leaf_node2, {                :parent_slug_list => [@root_directory_path, "toy"], :parent_title_list => [@root_directory_path.upcase, "Toy"] }).once

        @page_generator.generate_from_root_node(@root_node_with_two_levels)
      end
    end
  end

  describe "generate_html_content" do
    context "node with two children, both empty" do
      before :each do
        @parent_slug_list = ['qds','testing']
        @parent_title_list = ['QDS','Testing']
        @quarter = "Quarter 1 2012"
        @content = @page_generator.generate_html_content(@root_node, {
          :parent_slug_list => @parent_slug_list,
          :parent_title_list => @parent_title_list,
          :department => "Cabinet Office",
          :quarter => @quarter,
          :available_quarters => [{:title => "Quarter 1 2012", :slug => "q1-2012"}, {:title => "Quarter 2 2012", :slug => "q2-2012"}] })
      end
      it "should return a string containing two rows" do
        @content.should match /<td.*>.*Toy.*<\/td><td.*>.*100.*<\/td>/m
        @content.should match /<td.*>.*Test.*<\/td><td.*>.*200.*<\/td>/m
      end
      it "should set the data attributes for the row" do
        @content.should match /data-name="Toy"/
        @content.should match /data-total="100"/

        @content.should match /data-name="Test"/
        @content.should match /data-total="200"/

        @content.should_not match /data-url=/
      end
      it "should set the data attributes with department colours for the row" do
        @content.should match /data-colour="#0078ba"/
        @content.should match /data-font-colour="#fff"/
      end
      it "should set the page variable 'header-title'" do
        @content.should match /header-title: All Departments/
      end
      it "should set the page variable 'source-label'" do
        @content.should match "source-label: #{@source_label}"
      end
      it "should set the page variable 'total'" do
        @content.should match /total: £300/
      end
      it "should set the page variable 'total-value'" do
        @content.should match /total-value: 300/
      end
      it "should set the page variable list for breadcrumb links" do
        @content.should match /breadcrumbs:/
        @content.should include " - \"#{@parent_title_list[0]}\": /#{@parent_slug_list[0]}"
        @content.should include " - \"#{@parent_title_list[1]}\": /#{@parent_slug_list[0]}/#{@parent_slug_list[1]}"
      end
      it "should set the page variables for department header" do
        @content.should match /department-name: "Cabinet Office"/
        @content.should match /department-css-class: "cabinet-office"/
        @content.should match /department-css-suffix: "single-identity"/
      end
      it "should set the page variable 'quarter'" do
        @content.should include "quarter: #{@quarter}"
      end
      it "should set the page variable list for available quarters links" do
        @content.should match /available-quarters:/
        @content.should include " - \"Quarter 1 2012\": /#{@root_directory_path}/q1-2012"
        @content.should include " - \"Quarter 2 2012\": /#{@root_directory_path}/q2-2012"
      end
      it "should set the class for amounts" do
        @content.should match /class="amount"/
      end
    end

    context "node with unknown Department" do
      before :each do
        root_node = TablePageNode.new("All", 0.0, [TablePageNode.new("Test1", 100.0)])
        @content = @page_generator.generate_html_content(root_node, { :department => "Test Office" })
      end
      it "should return page variables for Department with raw data as name and no logo css values" do
        @content.should match /department-name: "Test Office"/
        @content.should_not match /department-css-class: ".+?"/
        @content.should_not match /department-css-suffix: ".+?"/
      end
      it "should set the data attributes for colour/font-colour to empty" do
        @content.should match /data-colour=""/
        @content.should match /data-font-colour=""/
      end
    end

    context "node with department level child nodes" do
      before :each do
        co_node = TablePageNode.new("CO", 100.0, [], "co", { :is_department => true, :alternative_title => "" })
        dcms_node = TablePageNode.new("Department for Culture, Media and Sport", 100.0, [], "Department for Culture, Media and Sport", { :is_department => true, :alternative_title => "" })
        hmrc_node = TablePageNode.new("HMRC", 100.0, [], "hmrc", { :is_department => true, :alternative_title => "" })

        root_node = TablePageNode.new("All", 0.0, [co_node, dcms_node, hmrc_node])
        @content = @page_generator.generate_html_content(root_node, {})
      end
      it "should return rows containing data attributes for department colours" do
        #CO
        @content.should match /data-colour="#0078ba"/
        @content.should match /data-font-colour="#fff"/
        #HO
        @content.should match /data-colour="#ee1089"/
        @content.should match /data-font-colour="#0A0C0C"/
        #HMRC
        @content.should match /data-colour=""/
        @content.should match /data-font-colour=""/
      end
    end

    context "node with known Department without crest" do
      it "should return page variables for Department with name and no logo css values" do
        root_node = TablePageNode.new("All", 0.0, [TablePageNode.new("Test1", 100.0)])
        content = @page_generator.generate_html_content(root_node, { :department => "HMRC" })

        content.should match /department-name: "HM Revenue & Customs"/
        content.should_not match /department-css-class: ".+?"/
        content.should_not match /department-css-suffix: ".+?"/
      end
    end

    context "node with one child with a child" do
      before :each do
        node1 = TablePageNode.new("Test1", 100.0)
        node2 = TablePageNode.new("Test2", 100.0, [node1])
        root_node = TablePageNode.new("All", 0.0, [node2])

        @content = @page_generator.generate_html_content(root_node)
      end
      it "should contain a data-url set" do
        @content.should match /data-url="test2"/
      end
      it "should contain a link" do
        @content.should match /<a href='test2'/
      end
    end

    context "node with very large and very small child values" do
      before :each do
        node1 = TablePageNode.new("Test1", 999100000.0)
        node2 = TablePageNode.new("Test2", 1100.0)
        node3 = TablePageNode.new("Test3", -1000000.0)
        root_node = TablePageNode.new("All", 0.0, [node1,node2,node3])

        @content = @page_generator.generate_html_content(root_node)
      end
      it "should display values formatted with uk currency format" do
        @content.should match /£999,100,000/
        @content.should match /£1,100/
        @content.should match /-£1,000,000/
      end
      it "should include a title tag in table cell with proper value to 2 decimal places" do
        @content.should match /title="999100000"/
      end
    end

    context "node with three children, all empty, not in order of value" do
      it "should return rows in order of value" do
        node1 = TablePageNode.new("Test1", -100.0)
        node2 = TablePageNode.new("Test2", 100.0)
        node3 = TablePageNode.new("Test3", 200.0)
        root_node = TablePageNode.new("All", 200.0, [node1,node2,node3])

        content = @page_generator.generate_html_content(root_node)
        content.should match /Test3.*Test2.*Test1/m
      end
    end

    context "node with alternative title" do
      it "should return with title using alternative title" do
        node2 = TablePageNode.new("Test2", 100.0)
        root_node = TablePageNode.new(
          "All", 200.0, [node2], "all", { :alternative_title => "Everything" })

        content = @page_generator.generate_html_content(root_node)
        content.should match /header-title: Everything/
      end
    end
  end

  describe "generate_csv_content" do
    context "node with two children, both empty" do
      before :each do
        @csv_content = @page_generator.generate_csv_content(@root_node, {})
      end
      it "should return a string with header row" do
        @csv_content.should match /"Name","Spend"/m
      end
      it "should return a string containing two rows for the nodes" do
        @csv_content.should match /"Toy","100"/m
        @csv_content.should match /"Test","200"/m
      end
    end
  end

  describe "generate_redirect_content" do
    it "should set the page-variable redirect url" do
      redirect_url = "/qds/q2-2012/yot/yot/spend-by-budget-type"
      redirect_content = @page_generator.generate_redirect_page_content(redirect_url)
      redirect_content.should include "redirect-url: \"#{redirect_url}\""
    end
  end

end