# encoding: utf-8
require_relative "../table_page_generator.rb"
require_relative "../model/table_page_node.rb"

describe "TablePageGenerator" do
  before(:each) do
    @root_directory_path = "_processors/spec/test_pages"
    @page_generator = TablePageGenerator.new(@root_directory_path)

    @child_node1 = TablePageNode.new("Toy", 100.0)
    @child_node2 = TablePageNode.new("Test", 200.0)
    @root_node = TablePageNode.new("All Departments", 300.0, [@child_node1, @child_node2], "")

    @empty_node = TablePageNode.new("Empty", 100.0)

    @leaf_node1 = TablePageNode.new("Toy 1", 100.0)
    @leaf_node2 = TablePageNode.new("Toy 2", 200.0)
    @child_node_not_empty = TablePageNode.new("Toy", 100.0, [@leaf_node1, @leaf_node2])
    @child_node_empty = TablePageNode.new("Empty", 200.0)
    @root_node_with_two_levels = TablePageNode.new("All Departments", 300.0, [@child_node_empty, @child_node_not_empty], "")
  end

  describe "#new" do
    it "takes one parameter and returns a TablePageGenerator object" do
      @page_generator.should be_an_instance_of TablePageGenerator
    end
  end

  describe "#root_directory_path" do
    it "returns the root directory path" do
      @page_generator.root_directory_path.should eq @root_directory_path
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
      @page_generator.stub(:generate_content).and_return(@test_content)
    end

    context "node with children" do
      it "creates an index.html file for the node containing test content" do
        @page_generator.should_receive(:generate_content).with(@root_node).once
        @page_generator.generate_for_node(@root_node)
        index_file = "#{@root_directory_path}/index.html"

        File.exists?(index_file).should be_true
        File.read(index_file).should eq (@test_content)
      end
    end

    context "node with no children" do
      it "does not create an index.html file for the node" do
        @page_generator.generate_for_node(@empty_node)
        File.exists?("#{@root_directory_path}/empty/index.html").should be_false
      end
    end

    context "node under parent slug" do
      it "creates an index.html file under the parent slug directory" do
        @page_generator.generate_for_node(@root_node, ['toy'])
        File.exists?("#{@root_directory_path}/toy/index.html").should be_true
      end
      it "creates an index.html file under the parent slug directory and own slug" do
        @page_generator.generate_for_node(@child_node_not_empty, ['test'])
        File.exists?("#{@root_directory_path}/test/toy/index.html").should be_true
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

      it "calls generate_for_node for each node passing parent slug path" do
        @page_generator.should_receive(:generate_for_node).with(@root_node_with_two_levels, []).once
        @page_generator.should_receive(:generate_for_node).with(@child_node_empty, []).once
        @page_generator.should_receive(:generate_for_node).with(@child_node_not_empty, []).once
        @page_generator.should_receive(:generate_for_node).with(@leaf_node1, ["toy"]).once
        @page_generator.should_receive(:generate_for_node).with(@leaf_node2, ["toy"]).once

        @page_generator.generate_from_root_node(@root_node_with_two_levels)
      end
    end
  end

  describe "generate_content" do
    context "node with two children, both empty" do
      before :each do
        @content = @page_generator.generate_content(@root_node)
      end
      it "should return a string containing a table with two rows" do
        @content.should match /<table.*<tr.*<\/tr>.*<tr.*<\/tr>.*<\/table>/m
        @content.should match /Test/
        @content.should match /Toy/
      end
    end
  end

end