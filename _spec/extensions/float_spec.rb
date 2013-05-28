# encoding: utf-8
require_relative "../../_processors/extensions/float"

describe "Float" do
  describe "to_magnitude_string" do
    it "should return 0 for 0.0" do
      0.0.to_magnitude_string.should eq "0"
    end
    it "should return 0.1 for 0.099999" do
      0.099999.to_magnitude_string.should eq "0.1"
    end
    it "should return 0.1 for 0.101" do
      0.101.to_magnitude_string.should eq "0.1"
    end
    it "should return 1 for 1.01" do
      1.01.to_magnitude_string.should eq "1"
    end
    it "should return 999 for 999.1" do
      999.1.to_magnitude_string.should eq "999"
    end
    it "should return 9k for 9049.0" do
      9049.0.to_magnitude_string.should eq "9k"
    end
    it "should return 9.9k for 9899.0" do
      9899.0.to_magnitude_string.should eq "9.9k"
    end
    it "should return 1.1m for 1100000.0" do
      1100000.0.to_magnitude_string.should eq "1.1m"
    end
    it "should return 99.9m for 99900000.0" do
      99900000.0.to_magnitude_string.should eq "99.9m"
    end
    it "should return 9bn for 9000000000.0" do
      9000000000.0.to_magnitude_string.should eq "9bn"
    end
    it "should return 9tn for 9000000000000.0" do
      9000000000000.0.to_magnitude_string.should eq "9tn"
    end
    it "should return -9k for -9049.0" do
      -9049.0.to_magnitude_string.should eq "-9k"
    end
  end

  describe "to_sterling_magnitude_string" do
    it "should return £0 for 0.0" do
      0.0.to_sterling_magnitude_string.should eq "£0"
    end
    it "should return £1.1m for 1100000.0" do
      1100000.0.to_sterling_magnitude_string.should eq "£1.1m"
    end
    it "should return -£9k for -9049.0" do
      -9049.0.to_sterling_magnitude_string.should eq "-£9k"
    end
  end

  describe "to_attribute_format" do
    it "should return 0 for 0.0" do
      0.0.to_attribute_format.should eq "0"
    end
    it "should return 100 for 100.0" do
      100.0.to_attribute_format.should eq "100"
    end
    it "should return 100 for 100.1" do
      100.1.to_attribute_format.should eq "100"
    end
  end
end