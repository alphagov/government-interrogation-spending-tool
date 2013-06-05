# encoding: utf-8

class QdsData

  QUARTER_GROUPING_REG_EX = /(Quarter )([0-9])( - )([0-9]{4})(\/[0-9]{2})/
  DEPARTMENT_ABBR_FROM_SCOPE = /(.+?) - Core/

	# Field names and order matches QDS spreadsheet column name and order
	attr_accessor :varname, :parent_department, :scope, :report_date, :section, :data_headline, :data_sub_type, :value, :abbr
    def initialize varname, parent_department, scope, report_date, section, data_headline, data_sub_type, value
        @varname = varname
        @parent_department = parent_department
        @scope = scope
        @report_date = report_date
        @section = section
        @data_headline = data_headline
        @data_sub_type = data_sub_type
        @value = value

        @abbr = QdsData.abbr_from_scope(@scope)
    end

    def to_s
      "QDS - varname = #{varname}, parent_department = #{parent_department}, scope = #{scope}, report_date = #{report_date}, section = #{section}, data_headline = #{data_headline}, data_sub_type = #{data_sub_type}, value = #{value.to_s}"
    end

    def self.abbr_from_scope(scope)
      scope.gsub(DEPARTMENT_ABBR_FROM_SCOPE, '\1').upcase
    end

    def self.quarter_short(report_date)
      report_date.gsub(QUARTER_GROUPING_REG_EX, 'Q\2 \4')
    end

    def self.quarter_long(report_date)
      report_date.gsub(QUARTER_GROUPING_REG_EX, 'Quarter \2 \4')
    end
end