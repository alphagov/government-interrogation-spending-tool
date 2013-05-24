# encoding: utf-8
require "fileutils"

class TablePageGenerator

  TABLE_PAGE_TEMPLATE_FILE_PATH = File.expand_path("#{File.dirname(__FILE__)}/templates/table_page.html")
  TABLE_ROWS_REPLACE_TAG = "<!--TABLE_CONTENT-->"
  TOTAL_REPLACE_TAG = "<!--TOTAL-->"
  HEADER_TITLE_REPLACE_TAG = "<!--HEADER_TITLE-->"
  INDEX_FILE_NAME = "index.html"

  attr_accessor :root_directory_path
  def initialize root_directory_path
    @root_directory_path = root_directory_path
    @table_page_template_content = File.read(TABLE_PAGE_TEMPLATE_FILE_PATH)
  end

  def delete_existing_files
    FileUtils.rm_rf Dir.glob("#{@root_directory_path}/*"), :secure => true
  end

  def generate_from_root_node(root_table_page_node)
    delete_existing_files
    generate_for_nodes(root_table_page_node)
  end

  def generate_for_nodes(table_page_node, parent_slug_list=[])
    generate_for_node(table_page_node, parent_slug_list)

    if !table_page_node.children.nil?
      slug_list = table_page_node.slug.empty? ? parent_slug_list : parent_slug_list + [table_page_node.slug]
      table_page_node.children.each { |node| generate_for_nodes(node, slug_list) }
    end
  end

  def generate_for_node(table_page_node, parent_slug_list=[])
    return if table_page_node.children.empty?

    parent_dir_path = parent_slug_list.empty? ? @root_directory_path : "#{@root_directory_path}/#{parent_slug_list.join('/')}"
    node_dir_path = table_page_node.slug.empty? ? parent_dir_path : "#{parent_dir_path}/#{table_page_node.slug}"
    file_path = "#{node_dir_path}/#{INDEX_FILE_NAME}"

    Dir::mkdir(parent_dir_path) unless File.exists?(parent_dir_path)
    Dir::mkdir(node_dir_path) unless File.exists?(node_dir_path)

    content = generate_content(table_page_node)

    File.open(file_path, 'w') {|f| f.write(content) }
  end

  def generate_content(table_page_node)
    rows = []
    table_page_node.children.each { |node| rows << "<tr><td>#{node.title}</td><td>#{node.total}</td></tr>" }
    table_rows = rows.join("\n")

    content = @table_page_template_content.clone
    content.sub!(TABLE_ROWS_REPLACE_TAG, table_rows)
    content.sub!(TOTAL_REPLACE_TAG, "£#{table_page_node.total.to_s}")
    content.sub!(HEADER_TITLE_REPLACE_TAG, table_page_node.title)

    content
  end
end