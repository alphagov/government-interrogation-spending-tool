# encoding: utf-8

class OscarData
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
end