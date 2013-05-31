# encoding: utf-8
require "fileutils"
require_relative "extensions/float"

class TablePageGenerator

  TABLE_PAGE_TEMPLATE_FILE_PATH = File.expand_path("#{File.dirname(__FILE__)}/templates/table_page.html")

  TABLE_ROWS_REPLACE_TAG = "<!--TABLE_CONTENT-->"
  TOTAL_REPLACE_TAG = "<!--TOTAL-->"
  TOTAL_VALUE_REPLACE_TAG = "<!--TOTAL_VALUE-->"
  HEADER_TITLE_REPLACE_TAG = "<!--HEADER_TITLE-->"
  SOURCE_LABEL_REPLACE_TAG = "<!--SOURCE_LABEL-->"
  BREADCRUMBS_LIST_REPLACE_TAG = "<!--BREADCRUMB_LIST-->"
  QUARTER_REPLACE_TAG = "<!--QUARTER-->"

  INDEX_FILE_NAME = "index.html"

  attr_accessor :root_directory_path, :source_label
  def initialize root_directory_path, source_label
    @root_directory_path = root_directory_path
    @source_label = source_label
    @table_page_template_content = File.read(TABLE_PAGE_TEMPLATE_FILE_PATH)
  end

  def delete_existing_files
    FileUtils.rm_rf Dir.glob("#{@root_directory_path}/*"), :secure => true
  end

  def generate_from_root_node(root_table_page_node)
    delete_existing_files
    generate_for_nodes(root_table_page_node, { :parent_slug_list => [@root_directory_path], :parent_title_list => [@root_directory_path.upcase] })
  end

  def generate_for_nodes(table_page_node, options = {})
    options[:quarter] = table_page_node.title if table_page_node.is_quarter

    generate_for_node(table_page_node, options)

    if !table_page_node.children.nil?
      parent_slug_list  = options.has_key?(:parent_slug_list) ? options[:parent_slug_list] : []
      parent_title_list = options.has_key?(:parent_title_list) ? options[:parent_title_list] : []

      child_options = options.clone
      child_options[:parent_slug_list]  = table_page_node.slug.empty? ? parent_slug_list  : parent_slug_list + [table_page_node.slug]
      child_options[:parent_title_list] = table_page_node.slug.empty? ? parent_title_list : parent_title_list + [table_page_node.title]

      table_page_node.children.each { |node| generate_for_nodes(node, child_options) }
    end
  end

  def generate_for_node(table_page_node, options = {})
    return if table_page_node.children.empty?

    parent_slug_list  = options.has_key?(:parent_slug_list) ? options[:parent_slug_list] : []
    parent_title_list = options.has_key?(:parent_title_list) ? options[:parent_title_list] : []

    parent_dir_path = parent_slug_list.empty? ? @root_directory_path : "#{parent_slug_list.join('/')}"
    node_dir_path = table_page_node.slug.empty? ? parent_dir_path : "#{parent_dir_path}/#{table_page_node.slug}"
    file_path = "#{node_dir_path}/#{INDEX_FILE_NAME}"

    Dir::mkdir(parent_dir_path) unless File.exists?(parent_dir_path)
    Dir::mkdir(node_dir_path) unless File.exists?(node_dir_path)

    content = generate_content(table_page_node, options)

    File.open(file_path, 'w') {|f| f.write(content) }
  end

  def generate_content(table_page_node, options = {})
    rows = []

    parent_slug_list  = options.has_key?(:parent_slug_list) ? options[:parent_slug_list] : []
    parent_title_list = options.has_key?(:parent_title_list) ? options[:parent_title_list] : []
    quarter           = options.has_key?(:quarter) ? options[:quarter] : nil

    table_page_node.children.sort { |a,b| b.total <=> a.total }.each do |node|
      row_title = node.has_children ? "<a href='#{node.slug}'>#{node.title}</a>" : node.title
      row = "<tr data-name=\"#{node.title}\" data-total=\"#{node.total.to_attribute_format}\" #{node.has_children ? "data-url=\"" + node.slug + "\"" : ""}>
  <td>#{row_title}</td><td class=\"amount\" title=\"#{node.total.to_attribute_format}\">#{node.total.to_uk_formatted_currency_string}</td>
</tr>"
      rows << row
    end

    table_rows = rows.join("\n")

    content = @table_page_template_content.clone
    content.sub!(TABLE_ROWS_REPLACE_TAG, table_rows)
    content.sub!(TOTAL_REPLACE_TAG, "#{table_page_node.total.to_sterling_magnitude_string}")
    content.sub!(TOTAL_VALUE_REPLACE_TAG, table_page_node.total.to_attribute_format)
    content.sub!(HEADER_TITLE_REPLACE_TAG, table_page_node.alternative_title_or_title.sub(':', ''))
    content.sub!(SOURCE_LABEL_REPLACE_TAG, @source_label)

    if !parent_slug_list.empty? && !parent_title_list.empty?
      breadcrumbs_list = ""
      for i in 0..parent_slug_list.length-1
        breadcrumbs_list += " - \"#{parent_title_list[i]}\": /#{parent_slug_list.slice(0..i).join('/')}\n"
      end
      breadcrumbs_list += " - \"#{table_page_node.title}\":  "

      content.sub!(BREADCRUMBS_LIST_REPLACE_TAG, breadcrumbs_list)
    else
      content.sub!(BREADCRUMBS_LIST_REPLACE_TAG, "")
    end

    if quarter
      content.sub!(QUARTER_REPLACE_TAG, quarter)
    end

    content
  end
end