# encoding: utf-8
require_relative "base_processor.rb"
require_relative "qds_csv_parser.rb"
require_relative "table_page_generator.rb"
require_relative "model/qds_data.rb"
require_relative "model/table_page_node.rb"

class QdsProcessor < BaseProcessor

  SPEND_BY_TYPE_OF_BUDGET = "Spend by Type of Budget"

  def csv_parser
    QdsCsvParser.new
  end

  def page_generator
    TablePageGenerator.new("qds", "QDS")
  end

  def root_node_options(data_objects)
    options = super

    options[:number_formatter_scale] = "m"

    report_date_hash = data_objects.group_by{ |qds_data| qds_data.report_date }
    available_quarters = []
    report_date_hash.keys.each do |report_date|
      available_quarters << {
        :title => QdsData.quarter_long(report_date),
        :slug => TablePageNode.slugify(QdsData.quarter_short(report_date)) }
    end
    options[:available_quarters] = available_quarters

    options
  end

  def generate_root_node(data_objects)

    grouped = {}
    grouped_totals = {}

    data_objects.map do |o|
      if !o.is_total
        grouped[o.report_date] = {} if !grouped.has_key? o.report_date
        grouped[o.report_date][o.abbr] = {} if !grouped[o.report_date].has_key? o.abbr
        grouped[o.report_date][o.abbr][o.parent_department] = {} if !grouped[o.report_date][o.abbr].has_key? o.parent_department
        grouped[o.report_date][o.abbr][o.parent_department][o.section] = {} if !grouped[o.report_date][o.abbr][o.parent_department].has_key? o.section
        grouped[o.report_date][o.abbr][o.parent_department][o.section][o.data_headline] = [] if !grouped[o.report_date][o.abbr][o.parent_department][o.section].has_key? o.data_headline

        grouped[o.report_date][o.abbr][o.parent_department][o.section][o.data_headline] << o
      else
        grouped_totals[o.report_date] = {} if !grouped_totals.has_key? o.report_date
        grouped_totals[o.report_date][o.abbr] = {} if !grouped_totals[o.report_date].has_key? o.abbr
        grouped_totals[o.report_date][o.abbr][o.parent_department] = {} if !grouped_totals[o.report_date][o.abbr].has_key? o.parent_department
        grouped_totals[o.report_date][o.abbr][o.parent_department][o.section] = {} if !grouped_totals[o.report_date][o.abbr][o.parent_department].has_key? o.section
        grouped_totals[o.report_date][o.abbr][o.parent_department][o.section][o.data_headline] = [] if !grouped_totals[o.report_date][o.abbr][o.parent_department][o.section].has_key? o.data_headline

        grouped_totals[o.report_date][o.abbr][o.parent_department][o.section][o.data_headline] << o
      end
    end

    root_children = []
    grouped.each_pair do |report_date, abbr_hash|
      report_date_total = 0.0
      report_date_children = []

      abbr_hash.each_pair do |abbr, parent_departments_hash|
        abbr_total = 0.0
        abbr_children = []

        parent_departments_hash.each_pair do |parent_department, sections_hash|
          parent_department_children = []

          sections_hash.each_pair do |section, data_headlines_hash|
            data_headline_totals = 0.0
            section_children = []

            data_headlines_hash.each_pair do |data_headline, spends|
              data_sub_types_total = 0.0
              data_headline_children = []

              spends.each do |s|
                data_sub_types_total += s.value
                data_headline_children << TablePageNode.new(
                  s.data_sub_type,
                  s.value)
              end

              begin
                data_headline_total = grouped_totals[report_date][abbr][parent_department][section][data_headline].first.value
              rescue Exception => e
                # use data_sub_type_total
                data_headline_total = data_sub_types_total
              end

              data_headline_totals += data_headline_total
              section_children << TablePageNode.new(
                data_headline,
                data_headline_total,
                data_headline_children)
            end

            begin
              section_total = grouped_totals[report_date][abbr][parent_department][section][QdsData::TOTAL_SPEND].first.value
            rescue Exception => e
              # use the sum from data_headline_totals
              section_total = data_headline_totals
            end

            parent_department_children << TablePageNode.new(
              section,
              section_total,
              section_children,
              section,
              { :alternative_layout => "table_qds_section" })
          end

          begin
            top_total = grouped_totals[report_date][abbr][parent_department][SPEND_BY_TYPE_OF_BUDGET][QdsData::TOP_TOTAL].first.value
          rescue Exception => e
            # use the spend type of budget total
            top_total = parent_department_children[0].total
          end

          abbr_total += top_total
          abbr_children << TablePageNode.new(
            parent_department,
            top_total,
            parent_department_children,
            parent_department,
            { :redirect_url => TablePageNode.slugify_paths_to_url("qds", QdsData.quarter_short(report_date), abbr, parent_department, SPEND_BY_TYPE_OF_BUDGET) })
        end

        report_date_total += abbr_total
        report_date_children << TablePageNode.new(
          abbr,
          abbr_total,
          abbr_children,
          abbr,
          { :is_department => true, :alternative_title => "", :table_header_name_label => "Department/Organisation" })
      end

      root_children << TablePageNode.new(
        QdsData.quarter_long(report_date),
        report_date_total,
        report_date_children,
        QdsData.quarter_short(report_date),
        { :is_quarter => true, :alternative_title => "All Departments", :table_header_name_label => "Department" })
    end

    root = TablePageNode.new(
      "All Quarters",
      0.0,
      root_children,
      "",
      { :alternative_layout => ROOT_NODE_LAYOUT, :table_header_name_label => "Quarter" })
  end
end