# encoding: utf-8
require_relative "base_processor.rb"
require_relative "oscar_csv_parser.rb"
require_relative "table_page_generator.rb"
require_relative "model/table_page_node.rb"

class OscarProcessor < BaseProcessor

  def csv_parser
    OscarCsvParser.new
  end

  def page_generator
    TablePageGenerator.new("oscar", "OSCAR 2012, date:15.01.12")
  end

  def generate_root_node(data_objects)

    grouped = {}

    data_objects.map do |o|
      grouped[o.quarter] = {} if !grouped.has_key? o.quarter
      grouped[o.quarter][o.segment_department_long_name] = {} if !grouped[o.quarter].has_key? o.segment_department_long_name
      grouped[o.quarter][o.segment_department_long_name][o.organisation] = {} if !grouped[o.quarter][o.segment_department_long_name].has_key? o.organisation
      grouped[o.quarter][o.segment_department_long_name][o.organisation][o.control_budget_code] = {} if !grouped[o.quarter][o.segment_department_long_name][o.organisation].has_key? o.control_budget_code
      grouped[o.quarter][o.segment_department_long_name][o.organisation][o.control_budget_code][o.economic_category_long_name] = [] if !grouped[o.quarter][o.segment_department_long_name][o.organisation][o.control_budget_code].has_key? o.economic_category_long_name

      grouped[o.quarter][o.segment_department_long_name][o.organisation][o.control_budget_code][o.economic_category_long_name] << o
    end

    root_children = []
    grouped.each_pair do |quarter, segment_department_long_name_hash|
      quarter_total = 0.0
      quarter_children = []

      segment_department_long_name_hash.each_pair do |segment_department_long_name, organisation_hash|
        segment_department_long_name_total = 0.0
        segment_department_long_name_children = []

        organisation_hash.each_pair do |organisation, control_budget_code_hash|
          organisation_total = 0.0
          organisation_children = []

          control_budget_code_hash.each_pair do |control_budget_code, economic_category_long_name_hash|
            control_budget_code_total = 0.0
            control_budget_code_children = []

            economic_category_long_name_hash.each_pair do |economic_category_long_name, spends|
              # sum economic_category_long_name spends as they are grouped by Sub Segment Long Name and month
              economic_category_long_name_total = spends.inject(0){|sum,s| sum += s.amount }
              control_budget_code_total += economic_category_long_name_total
              control_budget_code_children << TablePageNode.new(
                economic_category_long_name,
                economic_category_long_name_total)
            end

            organisation_total += control_budget_code_total
            organisation_children << TablePageNode.new(
              control_budget_code,
              control_budget_code_total,
              control_budget_code_children)
          end

          segment_department_long_name_total += organisation_total
          segment_department_long_name_children << TablePageNode.new(
            organisation,
            organisation_total,
            organisation_children)
        end

        quarter_total += segment_department_long_name_total
        quarter_children << TablePageNode.new(
          segment_department_long_name,
          segment_department_long_name_total,
          segment_department_long_name_children)
      end

      root_children << TablePageNode.new(
          "All Departments",
          quarter_total,
          quarter_children,
          OscarData.quarter_short(quarter))
    end

    root = TablePageNode.new("All Quarters", 0.0, root_children, "")
  end

end