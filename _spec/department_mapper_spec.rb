# encoding: utf-8
require_relative "../_processors/department_mapper.rb"

describe "DepartmentMapper" do
  describe "map_raw_to_css_hash" do
    it "takes a raw department reference and returns a hash with department abbr, name, css class, css logo suffix" do
      co_hash = { :abbr => "CO", :name => "Cabinet Office", :css_class => "cabinet-office", :css_logo_suffix => "single-identity"}
      DepartmentMapper.map_raw_to_css_hash("Cabinet Office").should eq(co_hash)
      DepartmentMapper.map_raw_to_css_hash("CO").should eq(co_hash)

      dfid_hash = { :abbr => "DFID", :name => "Department for International Development", :css_class => "department-for-international-development", :css_logo_suffix => "single-identity" }
      DepartmentMapper.map_raw_to_css_hash("Department for International Development").should eq(dfid_hash)
      DepartmentMapper.map_raw_to_css_hash("DfID").should eq(dfid_hash)
      DepartmentMapper.map_raw_to_css_hash("DfID").should eq(dfid_hash)

      DepartmentMapper.map_raw_to_css_hash("ZZZ").should eq nil
      DepartmentMapper.map_raw_to_css_hash("HMRC").should eq({ :abbr => "HMRC", :name => "HM Revenue & Customs" })
      DepartmentMapper.map_raw_to_css_hash("Crown Prosecution Service").should eq nil
    end
  end
end