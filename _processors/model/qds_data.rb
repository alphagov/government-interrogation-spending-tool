# encoding: utf-8

class QdsData

  QUARTER_GROUPING_REG_EX = /(Quarter )([0-9])( - )([0-9]{4})(\/)([0-9]{2})/
  DEPARTMENT_ABBR_FROM_SCOPE = /(.+?) - Core/

  TOTAL_SPEND = "Total Spend"
  TOP_TOTAL = "Top Total"

  CURRENT_QUARTER_TOTAL_VARNAMES = [
    "CQSpAB3SubTot",
    "CQSpAB2SubTot",
    "CQSpAB1SubTot",
    "CQSpAA2SubTot",
    "CQSpAC3SubTot",
    "CQSpAC3RecTot",
    "CQSpAA1SubTot",
    "CQSpAC2SubTot",
    "CQSpAB4SubTot",
    "CQSpAC1SubTot",
    "CQSpAATot",
    "CQSpABTot",
    "CQSpACTot",
    "CQSpAC1CompCatTot",
    "CQSpAC3GraCompTot",
    "CQSpATot",
    "CQSpAA2Comp3",
    "YTDSpAB4Pol7",
    "CQSpAB4Pol7",
    "CQSpAC1SupTot",
    "CQSpAC3GraTot"
  ]

	# Field names and order matches QDS spreadsheet column name and order
	attr_accessor :varname, :parent_department, :scope, :report_date, :section, :data_headline, :data_sub_type, :value, :metricName, :abbr
    def initialize varname, parent_department, scope, report_date, section, data_headline, data_sub_type, value, metricName
        @varname = varname.strip
        @parent_department = parent_department
        @scope = scope
        @report_date = report_date
        @section = section
        @data_headline = data_headline
        @data_sub_type = (!data_sub_type.nil? && !data_sub_type.empty?) ? data_sub_type : varname
        @value = value
        @metricName = metricName

        @abbr = QdsData.abbr_from_scope(@scope)
    end

    def to_s
      "QDS - varname = #{varname}, parent_department = #{parent_department}, scope = #{scope}, report_date = #{report_date}, section = #{section}, data_headline = #{data_headline}, data_sub_type = #{data_sub_type}, value = #{value.to_s}"
    end

    def self.abbr_from_scope(scope)
      scope.gsub(DEPARTMENT_ABBR_FROM_SCOPE, '\1').upcase
    end

    def self.quarter_short(report_date)
      report_date.gsub(QUARTER_GROUPING_REG_EX, 'Q\2 \4\6')
    end

    def self.quarter_long(report_date)
      report_date.gsub(QUARTER_GROUPING_REG_EX, 'Quarter \2 \4-\6')
    end

    def is_total
      CURRENT_QUARTER_TOTAL_VARNAMES.include?(varname)
    end
end