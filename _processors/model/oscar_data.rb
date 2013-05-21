# encoding: utf-8

class OscarData
	# Field names and order matches OSCAR spreadsheet column name and order
	attr_accessor :segment_department_long_name, :organisation, :control_budget_code, :economic_category_long_name, :quarter, :amount
    def initialize segment_department_long_name, organisation, control_budget_code, economic_category_long_name, quarter, amount
        @segment_department_long_name = segment_department_long_name
        @organisation = organisation
        @control_budget_code = control_budget_code
        @economic_category_long_name = economic_category_long_name
        @quarter = quarter
        @amount = amount
    end
end