# encoding: utf-8
class Float < Numeric

  REG_EX_REVERSE_ADD_COMMAS = /(\d{3})(?=\d)/
  REG_EX_REVERSE_ADD_COMMAS_REPLACE = '\\1,'

  def to_magnitude_string(magnitude=nil)
    val = self.to_f
    abs = val.abs
    result = sprintf('%.1f', val)

    if    magnitude == "tn" || (magnitude.nil? && abs >= 1000000000000)
      result = sprintf('%.1f', val/1000000000000).reverse.gsub(REG_EX_REVERSE_ADD_COMMAS, REG_EX_REVERSE_ADD_COMMAS_REPLACE).reverse + "tn"
    elsif magnitude == "bn" || (magnitude.nil? && abs >= 1000000000)
      result = sprintf('%.1f', val/1000000000).reverse.gsub(REG_EX_REVERSE_ADD_COMMAS, REG_EX_REVERSE_ADD_COMMAS_REPLACE).reverse + "bn"
    elsif magnitude == "m" ||  (magnitude.nil? && abs >= 1000000)
      result = sprintf('%.1f', val/1000000).reverse.gsub(REG_EX_REVERSE_ADD_COMMAS, REG_EX_REVERSE_ADD_COMMAS_REPLACE).reverse + "m"
    elsif magnitude == "k" ||  (magnitude.nil? && abs >= 1000)
      result = sprintf('%.1f', val/1000).reverse.gsub(REG_EX_REVERSE_ADD_COMMAS, REG_EX_REVERSE_ADD_COMMAS_REPLACE).reverse + "k"
    end

    result.gsub(/([0-9]{3})(\.[0-9]+)([a-z]*)/, '\1\3').sub(".0","")
  end

  def to_sterling_magnitude_string
    result = "£" + self.to_magnitude_string
    result.sub("£-", "-£")
  end

  def to_attribute_format
    sprintf('%.0f', self.to_f)
  end

  def to_uk_formatted_currency_string(magnitude=nil)
    if magnitude.nil?
      result = "£" + self.to_attribute_format.reverse.gsub(REG_EX_REVERSE_ADD_COMMAS, REG_EX_REVERSE_ADD_COMMAS_REPLACE).reverse
      result.sub("£-", "-£")
    else
      result = "£" + self.to_magnitude_string(magnitude)
      result.sub("£-", "-£")
    end
  end
end