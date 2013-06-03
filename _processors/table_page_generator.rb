# encoding: utf-8
require "fileutils"
require_relative "extensions/float"
require_relative "department_mapper"

class TablePageGenerator

  TABLE_PAGE_TEMPLATE_FILE_PATH = File.expand_path("#{File.dirname(__FILE__)}/templates/table_page.html")
  TABLE_PAGE_CHART_PLACEHOLDER_IMAGE_FILE_PATH = File.expand_path("#{File.dirname(__FILE__)}/templates/chart.png")

  TABLE_ROWS_REPLACE_TAG = "<!--TABLE_CONTENT-->"
  TOTAL_REPLACE_TAG = "<!--TOTAL-->"
  TOTAL_VALUE_REPLACE_TAG = "<!--TOTAL_VALUE-->"
  HEADER_TITLE_REPLACE_TAG = "<!--HEADER_TITLE-->"
  SOURCE_LABEL_REPLACE_TAG = "<!--SOURCE_LABEL-->"
  BREADCRUMBS_LIST_REPLACE_TAG = "<!--BREADCRUMB_LIST-->"
  QUARTER_REPLACE_TAG = "<!--QUARTER-->"
  AVAILABLE_QUARTERS_REPLACE_TAG = "<!--AVAILABLE_QUARTERS-->"
  DEPARTMENT_NAME_REPLACE_TAG = "<!--DEPARTMENT_NAME-->"
  DEPARTMENT_CSS_CLASS_REPLACE_TAG = "<!--DEPARTMENT_CSS_CLASS-->"
  DEPARTMENT_CSS_SUFFIX_REPLACE_TAG = "<!--DEPARTMENT_CSS_SUFFIX-->"

  INDEX_FILE_NAME = "index.html"
  CSV_FILE_NAME   = "data.csv"

  attr_accessor :root_directory_path, :source_label
  def initialize root_directory_path, source_label
    @root_directory_path = root_directory_path
    @source_label = source_label
    @table_page_template_content = File.read(TABLE_PAGE_TEMPLATE_FILE_PATH)
  end

  def delete_existing_files
    FileUtils.rm_rf Dir.glob("#{@root_directory_path}/*"), :secure => true
  end

  def generate_from_root_node(root_table_page_node, options = {})
    options = {
        :parent_slug_list => [@root_directory_path],
        :parent_title_list => [@root_directory_path.upcase]
      }.merge(options)

    delete_existing_files
    generate_for_nodes(root_table_page_node, options)
  end

  def generate_for_nodes(table_page_node, options = {})
    options[:quarter]    = table_page_node.title if table_page_node.is_quarter
    options[:department] = table_page_node.title if table_page_node.is_department

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

    Dir::mkdir(parent_dir_path) unless File.exists?(parent_dir_path)
    Dir::mkdir(node_dir_path) unless File.exists?(node_dir_path)

    html_content = generate_html_content(table_page_node, options)
    index_file_path = "#{node_dir_path}/#{INDEX_FILE_NAME}"
    File.open(index_file_path, 'w') {|f| f.write(html_content) }

    csv_content = generate_csv_content(table_page_node, options)
    csv_file_path = "#{node_dir_path}/#{CSV_FILE_NAME}"
    File.open(csv_file_path, 'w') {|f| f.write(csv_content) }

    FileUtils.cp TABLE_PAGE_CHART_PLACEHOLDER_IMAGE_FILE_PATH, "#{node_dir_path}/chart.png"
  end

  def generate_html_content(table_page_node, options = {})
    rows = []

    parent_slug_list   = options.has_key?(:parent_slug_list) ? options[:parent_slug_list] : []
    parent_title_list  = options.has_key?(:parent_title_list) ? options[:parent_title_list] : []
    department         = options.has_key?(:department) ? options[:department] : nil
    quarter            = options.has_key?(:quarter) ? options[:quarter] : nil
    available_quarters = options.has_key?(:available_quarters) ? options[:available_quarters] : nil

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

    department_name = ""
    department_css_class = ""
    department_css_suffix = ""
    if department
      department_hash = DepartmentMapper.map_raw_to_css_hash(department)
      if department_hash
        department_name       = "\"#{department_hash[:name]}\"" if department_hash.has_key?(:name)
        department_css_class  = "\"#{department_hash[:css_class]}\"" if department_hash.has_key?(:css_class)
        department_css_suffix = "\"#{department_hash[:css_logo_suffix]}\"" if department_hash.has_key?(:css_logo_suffix)
      else
        department_name = "\"#{department}\""
      end
    end
    content.sub!(DEPARTMENT_NAME_REPLACE_TAG, department_name)
    content.sub!(DEPARTMENT_CSS_CLASS_REPLACE_TAG, department_css_class)
    content.sub!(DEPARTMENT_CSS_SUFFIX_REPLACE_TAG, department_css_suffix)

    if quarter
      content.sub!(QUARTER_REPLACE_TAG, quarter)
    else
      content.sub!(QUARTER_REPLACE_TAG, "")
    end

    available_quarters_list = ""
    if available_quarters
      available_quarters.each do |available_quarter|
        available_quarters_list += "\n - \"#{available_quarter[:title]}\": /#{@root_directory_path}/#{available_quarter[:slug]}"
      end
    end
    content.sub!(AVAILABLE_QUARTERS_REPLACE_TAG, available_quarters_list)

    content
  end

  def generate_csv_content(table_page_node, options = {})
    rows = ["\"Name\",\"Spend\""]

    table_page_node.children.each do |node|
      rows << "\"#{node.title}\",\"#{node.total.to_attribute_format}\""
    end

    rows.join("\n")
  end
end