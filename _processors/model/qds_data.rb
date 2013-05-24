# encoding: utf-8

class QdsData
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
end