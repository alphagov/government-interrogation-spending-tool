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
    it "should return 0.101 for 0.101" do
      0.101.to_magnitude_string.should eq "0.101"
    end
    it "should return 1.01 for 1.011" do
      1.011.to_magnitude_string.should eq "1.01"
    end
    it "should return 999 for 999.1" do
      999.1.to_magnitude_string.should eq "999"
    end
    it "should return 9.05k for 9049.0" do
      9049.0.to_magnitude_string.should eq "9.05k"
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
    it "should return -9.05k for -9049.0" do
      -9049.0.to_magnitude_string.should eq "-9.05k"
    end

    it "should return scaled to millions when using specific magnitude m" do
      999000.0.to_magnitude_string('m').should eq "0.999m"
      9900000.0.to_magnitude_string('m').should eq "9.9m"
      9990000.0.to_magnitude_string('m').should eq "9.99m"
      9990000000.0.to_magnitude_string('m').should eq "9,990m"
    end

    it "should return scaled to thousands when using specific magnitude k" do
      999000.0.to_magnitude_string('k').should eq "999k"
      9990000.0.to_magnitude_string('k').should eq "9,990k"
      9990000000.0.to_magnitude_string('k').should eq "9,990,000k"
    end

    it "should return value with specific max decimal places" do
      0.101.to_magnitude_string(nil, 1).should eq "0.1"
      0.101.to_magnitude_string(nil, 0).should eq "0"
      999000.0.to_magnitude_string('m', 0).should eq "1m"
      9900000.0.to_magnitude_string('m', 1).should eq "9.9m"
    end
  end

  describe "to_sterling_magnitude_string" do
    it "should return £0 for 0.0" do
      0.0.to_sterling_magnitude_string.should eq "£0"
    end
    it "should return £1.1m for 1100000.0" do
      1100000.0.to_sterling_magnitude_string.should eq "£1.1m"
    end
    it "should return -£9.05k for -9049.0" do
      -9049.0.to_sterling_magnitude_string.should eq "-£9.05k"
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

  describe "to_uk_formatted_currency_string" do
    it "should return £0 for 0.0" do
      0.0.to_uk_formatted_currency_string.should eq "£0"
    end
    it "should return £1,100,000 for 1100000.0" do
      1100000.0.to_uk_formatted_currency_string.should eq "£1,100,000"
    end
    it "should return -£9,049 for -9049.0" do
      -9049.0.to_uk_formatted_currency_string.should eq "-£9,049"
    end

    it "should return scaled to millions when using specific magnitude m" do
      999000.0.to_uk_formatted_currency_string('m').should eq "£0.999m"
      9900000.0.to_uk_formatted_currency_string('m').should eq "£9.9m"
      9990000.0.to_uk_formatted_currency_string('m').should eq "£9.99m"
      9990000000.0.to_uk_formatted_currency_string('m').should eq "£9,990m"
      -9990000.0.to_uk_formatted_currency_string('m').should eq "-£9.99m"
    end
    it "should return scaled to thousands when using specific magnitude k" do
      999000.0.to_uk_formatted_currency_string('k').should eq "£999k"
      9990000.0.to_uk_formatted_currency_string('k').should eq "£9,990k"
      9990000000.0.to_uk_formatted_currency_string('k').should eq "£9,990,000k"
      -9990000.0.to_uk_formatted_currency_string('k').should eq "-£9,990k"
    end
    it "should return scaled to millions with zero decimal places when using specific magnitude m and set decimal places" do
      999000.0.to_uk_formatted_currency_string('m', 0).should eq "£1m"
      9900000.0.to_uk_formatted_currency_string('m', 0).should eq "£10m"
      9990000.0.to_uk_formatted_currency_string('m', 0).should eq "£10m"
      9990000000.0.to_uk_formatted_currency_string('m', 0).should eq "£9,990m"
      -9990000.0.to_uk_formatted_currency_string('m', 0).should eq "-£10m"
    end
  end
end