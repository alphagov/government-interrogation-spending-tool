# encoding: utf-8

class QdsData

  QUARTER_GROUPING_REG_EX = /(Quarter )([0-9])( - )([0-9]{4})(\/[0-9]{2})/

	# Field names and order matches QDS spreadsheet column name and order
	attr_accessor :parent_department, :report_date, :section, :data_headline, :data_sub_type, :value
    def initialize parent_department, report_date, section, data_headline, data_sub_type, value
        @parent_department = parent_department
        @report_date = report_date
        @section = section
        @data_headline = data_headline
        @data_sub_type = data_sub_type
        @value = value
    end

    def to_s
      "QDS - parent_department = #{parent_department}, report_date = #{report_date}, section = #{section}, data_headline = #{data_headline}, data_sub_type = #{data_sub_type}, value = #{value.to_s}"
    end

    def self.quarter_short(report_date)
      report_date.gsub(QUARTER_GROUPING_REG_EX, 'Q\2 \4')
    end

    def self.quarter_long(report_date)
      report_date.gsub(QUARTER_GROUPING_REG_EX, 'Quarter \2 \4')
    end
end