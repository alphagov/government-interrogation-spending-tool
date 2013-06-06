# encoding: utf-8

class BaseProcessor

  ROOT_NODE_LAYOUT = "table_root"

  def csv_parser
    raise "this method should be overridden and return a csv parser"
  end

  def page_generator
    raise "this method should be overridden and return a page generator"
  end

  def root_node_options(data_objects)
    {}
  end

  def generate_root_node(data_objects)
    raise "this method should be overridden and return the root node and children for the data objects"
  end

	def process(file_full_path)
    data_objects = csv_parser.parse_file(file_full_path)
    root_node = generate_root_node(data_objects)
    page_generator.generate_from_root_node(root_node, root_node_options(data_objects))
	end
end