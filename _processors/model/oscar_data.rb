# encoding: utf-8

class OscarData

  QUARTER_GROUPING_REG_EX = /(Qtr)([0-9])( - )([0-9]{2})(-[0-9]{2})/

	# Field names and order matches OSCAR spreadsheet column name and order
	attr_accessor :organisation, :control_budget_code, :segment_department_long_name, :economic_category_long_name, :quarter, :month, :amount
    def initialize organisation, control_budget_code, segment_department_long_name, economic_category_long_name, quarter, month, amount
        @organisation = organisation
        @control_budget_code = control_budget_code
        @segment_department_long_name = segment_department_long_name
        @economic_category_long_name = economic_category_long_name
        @quarter = quarter
        @month = month
        @amount = amount
    end

    def to_s
      "OSCAR - organisation = #{organisation}, control_budget_code = #{control_budget_code}, segment_department_long_name = #{segment_department_long_name}, economic_category_long_name = #{economic_category_long_name}, quarter = #{quarter}, month = #{month}, amount = #{amount}"
    end

    def self.quarter_short(quarter)
      quarter.gsub(QUARTER_GROUPING_REG_EX, 'Q\2 20\4\5')
    end

    def self.quarter_long(quarter)
      quarter.gsub(QUARTER_GROUPING_REG_EX, 'Quarter \2 20\4\5')
    end
end