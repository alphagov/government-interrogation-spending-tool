# encoding: utf-8

class QdsData
	attr_accessor :parent_department, :report_date, :section, :data_headline, :data_sub_type, :value
    def initialize parent_department, report_date, section, data_headline, data_sub_type, value
        @parent_department = parent_department
        @report_date = report_date
        @section = section
        @data_headline = data_headline
        @data_sub_type = data_sub_type
        @value = value
    end
end