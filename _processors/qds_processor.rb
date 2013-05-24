# encoding: utf-8
require_relative "base_processor.rb"
require_relative "qds_csv_parser.rb"
require_relative "table_page_generator.rb"
require_relative "model/table_page_node.rb"

class QdsProcessor < BaseProcessor

  def csv_parser
    QdsCsvParser.new
  end

  def page_generator
    TablePageGenerator.new("qds")
  end

  def generate_root_node(data_objects)

    grouped = {}

    data_objects.map do |o|
      grouped[o.report_date] = {} if !grouped.has_key? o.report_date
      grouped[o.report_date][o.parent_department] = {} if !grouped[o.report_date].has_key? o.parent_department
      grouped[o.report_date][o.parent_department][o.section] = {} if !grouped[o.report_date][o.parent_department].has_key? o.section
      grouped[o.report_date][o.parent_department][o.section][o.data_headline] = [] if !grouped[o.report_date][o.parent_department][o.section].has_key? o.data_headline

      grouped[o.report_date][o.parent_department][o.section][o.data_headline] << o
    end

    root_children = []
    grouped.each_pair do |report_date, parent_departments_hash|
      report_date_total = 0.0
      report_date_children = []

      parent_departments_hash.each_pair do |parent_department, sections_hash|
        parent_department_children = []

        sections_hash.each_pair do |section, data_headlines_hash|
          section_total = 0.0
          section_children = []

          data_headlines_hash.each_pair do |data_headline, spends|
            data_headline_total = 0.0
            data_headline_children = []

            spends.each do |s|
              data_headline_total += s.value
              data_headline_children << TablePageNode.new(
                s.data_sub_type,
                s.data_sub_type,
                s.value)
            end

            section_total += data_headline_total
            section_children << TablePageNode.new(
              data_headline,
              data_headline,
              data_headline_total,
              data_headline_children)
          end

          parent_department_children << TablePageNode.new(
            section,
            section,
            section_total,
            section_children)
        end

        # QDS sections are different views on the same spending, so totals are equal
        parent_department_total = parent_department_children[0].total
        report_date_total += parent_department_total
        report_date_children << TablePageNode.new(
          parent_department,
          parent_department,
          parent_department_total,
          parent_department_children)
      end

      root_children << TablePageNode.new(
        report_date,
        "All Departments",
        report_date_total,
        report_date_children
      )
    end

    root = TablePageNode.new("","All Departments", 0.0, root_children)
  end
end