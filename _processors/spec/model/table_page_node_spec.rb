# encoding: utf-8
require_relative "../../model/table_page_node.rb"

describe "TablePageNode" do
  before :all do
    @child_node1 = TablePageNode.new("Toy", 100.0)
    @child_node2 = TablePageNode.new("Test", 200.0)
    @root_node = TablePageNode.new("All Departments", 300.0, [@child_node1, @child_node2], "")
  end

  describe "#new" do
    it "takes 2 parameters and returns a TablePageNode object" do
      TablePageNode.new("Toy", 100.0).should be_an_instance_of TablePageNode
    end
    it "takes 3 parameters and returns a TablePageNode object" do
      TablePageNode.new("Toy", 100.0, [@child_node1, @child_node2]).should be_an_instance_of TablePageNode
    end
    it "takes 4 parameters and returns a TablePageNode object" do
      @root_node.should be_an_instance_of TablePageNode
    end
  end

  describe "#slug" do
    it "returns the slug" do
      @child_node1.slug.should eq "toy"
    end

    it "should use slug if slug is provided" do
      TablePageNode.new("Toy", 100.0, [], "Different String").slug.should eq "different-string"
    end

    it "should use title if slug is not provided" do
      TablePageNode.new("Cost's Title 123", 100.0).slug.should eq "costs-title-123"
    end
  end
  describe "#title" do
    it "returns the title" do
      @child_node1.title.should eq "Toy"
    end
  end
  describe "#total" do
    it "returns the total" do
      @child_node1.total.should eq 100.0
    end
  end
  describe "#children" do
    it "returns the children" do
      @child_node1.children.should eq []
      @root_node.children.should eq [@child_node1, @child_node2]
    end
  end

  describe "has_children" do
    it "returns false if children is empty" do
      @child_node1.has_children.should be_false
    end
    it "returns true if children is not empty" do
      @root_node.has_children.should be_true
    end
  end
end