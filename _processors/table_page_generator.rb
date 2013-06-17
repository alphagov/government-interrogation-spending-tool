# encoding: utf-8
require "fileutils"
require_relative "extensions/float"
require_relative "department_mapper"

class TablePageGenerator

  TABLE_PAGE_TEMPLATE_FILE_PATH = File.expand_path("#{File.dirname(__FILE__)}/templates/table_page.html")
  TABLE_PAGE_CHART_PLACEHOLDER_IMAGE_FILE_PATH = File.expand_path("#{File.dirname(__FILE__)}/templates/chart.png")
  REDIRECT_PAGE_TEMPLATE_FILE_PATH = File.expand_path("#{File.dirname(__FILE__)}/templates/redirect_page.html")

  DEFAULT_LAYOUT = "table"
  DEFAULT_TABLE_HEADER_NAME_LABEL = "Name"

  LAYOUT_REPLACE_TAG = "<!--LAYOUT-->"
  TABLE_ROWS_REPLACE_TAG = "<!--TABLE_CONTENT-->"
  TOTAL_REPLACE_TAG = "<!--TOTAL-->"
  TOTAL_ROW_LABEL_REPLACE_TAG = "<!--TOTAL_ROW_LABEL-->"
  TOTAL_VALUE_REPLACE_TAG = "<!--TOTAL_VALUE-->"
  HEADER_TITLE_REPLACE_TAG = "<!--HEADER_TITLE-->"
  SOURCE_LABEL_REPLACE_TAG = "<!--SOURCE_LABEL-->"
  DISPLAY_FOI_REPLACE_TAG = "<!--DISPLAY_FOI-->"
  TABLE_HEADER_NAME_LABEL_REPLACE_TAG = "<!--TABLE_HEADER_NAME_LABEL-->"
  BREADCRUMBS_LIST_REPLACE_TAG = "<!--BREADCRUMB_LIST-->"
  QUARTER_REPLACE_TAG = "<!--QUARTER-->"
  AVAILABLE_QUARTERS_REPLACE_TAG = "<!--AVAILABLE_QUARTERS-->"
  DEPARTMENT_NAME_REPLACE_TAG = "<!--DEPARTMENT_NAME-->"
  DEPARTMENT_CSS_CLASS_REPLACE_TAG = "<!--DEPARTMENT_CSS_CLASS-->"
  DEPARTMENT_CSS_SUFFIX_REPLACE_TAG = "<!--DEPARTMENT_CSS_SUFFIX-->"

  REDIRECT_URL_REPLACE_TAG = "<!--REDIRECT_URL-->"

  INDEX_FILE_NAME = "index.html"
  CSV_FILE_NAME   = "data.csv"

  attr_accessor :root_directory_path, :source_label
  def initialize root_directory_path, source_label
    @root_directory_path = root_directory_path
    @source_label = source_label

    @table_page_template_content = File.read(TABLE_PAGE_TEMPLATE_FILE_PATH)
    @redirect_page_template_content = File.read(REDIRECT_PAGE_TEMPLATE_FILE_PATH)
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
    options[:quarter]    = table_page_node.title.to_s.downcase if table_page_node.is_quarter
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
    return if table_page_node.children.empty? && !table_page_node.force_generate_with_no_children

    parent_slug_list  = options.has_key?(:parent_slug_list) ? options[:parent_slug_list] : []
    parent_title_list = options.has_key?(:parent_title_list) ? options[:parent_title_list] : []

    parent_dir_path = parent_slug_list.empty? ? @root_directory_path : "#{parent_slug_list.join('/')}"
    node_dir_path = table_page_node.slug.empty? ? parent_dir_path : "#{parent_dir_path}/#{table_page_node.slug}"

    Dir::mkdir(parent_dir_path) unless File.exists?(parent_dir_path)
    Dir::mkdir(node_dir_path) unless File.exists?(node_dir_path)

    if !table_page_node.redirect_url
      html_content = generate_html_content(table_page_node, options)
      index_file_path = "#{node_dir_path}/#{INDEX_FILE_NAME}"
      File.open(index_file_path, 'w') {|f| f.write(html_content) }

      csv_content = generate_csv_content(table_page_node, options)
      csv_file_path = "#{node_dir_path}/#{CSV_FILE_NAME}"
      File.open(csv_file_path, 'w') {|f| f.write(csv_content) }

      FileUtils.cp TABLE_PAGE_CHART_PLACEHOLDER_IMAGE_FILE_PATH, "#{node_dir_path}/chart.png"
    else
      redirect_content = generate_redirect_page_content(table_page_node.redirect_url)
      index_file_path = "#{node_dir_path}/#{INDEX_FILE_NAME}"
      File.open(index_file_path, 'w') {|f| f.write(redirect_content) }
    end
  end

  def generate_html_content(table_page_node, options = {})
    rows = []

    filter_zero_rows                = options.has_key?(:filter_zero_rows) ? options[:filter_zero_rows] : true
    parent_slug_list                = options.has_key?(:parent_slug_list) ? options[:parent_slug_list] : []
    parent_title_list               = options.has_key?(:parent_title_list) ? options[:parent_title_list] : []
    department                      = options.has_key?(:department) ? options[:department] : nil
    quarter                         = options.has_key?(:quarter).to_s.downcase ? options[:quarter] : nil
    available_quarters              = options.has_key?(:available_quarters) ? options[:available_quarters] : nil
    number_formatter_scale          = options.has_key?(:number_formatter_scale) ? options[:number_formatter_scale] : nil
    number_formatter_decimal_places = options.has_key?(:number_formatter_decimal_places) ? options[:number_formatter_decimal_places] : 0

    department_name = ""
    department_css_class = ""
    department_css_suffix = ""
    department_colour = ""
    department_font_colour = ""
    if department
      department_hash = DepartmentMapper.map_raw_to_css_hash(department)
      if department_hash
        department_name       = "\"#{department_hash[:name]}\"" if department_hash.has_key?(:name)
        department_css_class  = "\"#{department_hash[:css_class]}\"" if department_hash.has_key?(:css_class)
        department_css_suffix = "\"#{department_hash[:css_logo_suffix]}\"" if department_hash.has_key?(:css_logo_suffix)

        department_colour      = department_hash[:colour] if department_hash.has_key?(:colour)
        department_font_colour = department_hash[:font_colour] if department_hash.has_key?(:font_colour)
      else
        department_name = "\"#{department}\""
      end
    end

    table_page_node.children.sort { |a,b| b.total <=> a.total }.each do |node|
      next if filter_zero_rows && node.total == 0.0

      data_abbr = nil
      data_colour = department_colour
      data_font_colour = department_font_colour
      if node.is_department
        child_department_hash = DepartmentMapper.map_raw_to_css_hash(node.title)
        if child_department_hash
          data_abbr        = child_department_hash[:abbr] if child_department_hash.has_key?(:abbr)
          data_colour      = child_department_hash[:colour] if child_department_hash.has_key?(:colour)
          data_font_colour = child_department_hash[:font_colour] if child_department_hash.has_key?(:font_colour)
        end
      end

      row_title = node.has_children ? "<a href='#{node.slug}'>#{node.title}</a>" : node.title
      row_total_label = node.total.to_uk_formatted_currency_string(number_formatter_scale, number_formatter_decimal_places)
      row = "<tr data-name=\"#{node.title}\" "\
                "data-total=\"#{node.total.to_attribute_format}\" "\
                "data-total-label=\"#{row_total_label}\" "\
                "data-colour=\"#{data_colour}\" data-font-colour=\"#{data_font_colour}\""\
                "#{node.has_children ? "data-url=\"" + node.slug + "\"" : ""} "\
                "#{!data_abbr.nil? ? "data-abbr=\"" + data_abbr + "\"" : ""} "\
                ">
  <td>#{row_title}</td><td class=\"amount\" title=\"#{node.total.to_attribute_format}\">#{row_total_label}</td>
</tr>"
      rows << row
    end

    table_rows = rows.join("\n")

    content = @table_page_template_content.clone

    layout = table_page_node.alternative_layout ? table_page_node.alternative_layout : DEFAULT_LAYOUT
    content.sub!(LAYOUT_REPLACE_TAG, layout)

    content.sub!(TABLE_ROWS_REPLACE_TAG, table_rows)
    content.sub!(TOTAL_REPLACE_TAG, "#{table_page_node.total.to_sterling_magnitude_string}")
    content.sub!(TOTAL_ROW_LABEL_REPLACE_TAG, "#{table_page_node.total.to_uk_formatted_currency_string(number_formatter_scale, number_formatter_decimal_places)}")
    content.sub!(TOTAL_VALUE_REPLACE_TAG, table_page_node.total.to_attribute_format)
    content.sub!(HEADER_TITLE_REPLACE_TAG, table_page_node.alternative_title_or_title.sub(':', ''))
    content.sub!(SOURCE_LABEL_REPLACE_TAG, @source_label)

    table_header_name_label = table_page_node.table_header_name_label ? table_page_node.table_header_name_label : DEFAULT_TABLE_HEADER_NAME_LABEL
    content.sub!(TABLE_HEADER_NAME_LABEL_REPLACE_TAG, "\"" + table_header_name_label + "\"")

    display_foi = table_page_node.display_foi ? table_page_node.display_foi.to_s : "false"
    content.sub!(DISPLAY_FOI_REPLACE_TAG, display_foi)

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

  def generate_redirect_page_content(redirect_url)
    content = @redirect_page_template_content.clone
    content.sub(REDIRECT_URL_REPLACE_TAG, "\"#{redirect_url}\"")
  end
end