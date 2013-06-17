# encoding: utf-8
class Float < Numeric

  REG_EX_REVERSE_ADD_COMMAS = /(\d{3})(?=\d)/
  REG_EX_REVERSE_ADD_COMMAS_REPLACE = '\\1,'

  def to_magnitude_string(magnitude=nil, max_decimal_points=nil)
    val = self.to_f
    mag_val = val
    suffix = ""
    decimal_points = 1
    abs = val.abs
    result = sprintf('%.1f', val)

    if    magnitude == "tn" || (magnitude.nil? && abs >= 1000000000000)
      mag_val = val/1000000000000
      suffix = "tn"
    elsif magnitude == "bn" || (magnitude.nil? && abs >= 1000000000)
      mag_val = val/1000000000
      suffix = "bn"
    elsif magnitude == "m" ||  (magnitude.nil? && abs >= 1000000)
      mag_val = val/1000000
      suffix = "m"
    elsif magnitude == "k" ||  (magnitude.nil? && abs >= 1000)
      mag_val = val/1000
      suffix = "k"
    end

    decimal_points = mag_val.abs < 1 ? 3 : mag_val.abs < 10 ? 2 : mag_val.abs < 100 ? 1 : 0
    decimal_points = !max_decimal_points.nil? && decimal_points > max_decimal_points ? max_decimal_points : decimal_points

    result = sprintf("%.#{decimal_points}f", mag_val)
    result.sub!(/(?:(\..*[^0])0+|\.0+)$/, '\1')
    result = result.reverse.gsub(REG_EX_REVERSE_ADD_COMMAS, REG_EX_REVERSE_ADD_COMMAS_REPLACE).reverse + suffix

    result
  end

  def to_sterling_magnitude_string
    result = "£" + self.to_magnitude_string
    result.sub("£-", "-£")
  end

  def to_attribute_format
    sprintf('%.0f', self.to_f)
  end

  def to_uk_formatted_currency_string(magnitude=nil, decimal_points=nil)
    if magnitude.nil?
      result = "£" + self.to_attribute_format.reverse.gsub(REG_EX_REVERSE_ADD_COMMAS, REG_EX_REVERSE_ADD_COMMAS_REPLACE).reverse
      result.sub("£-", "-£")
    else
      result = "£" + self.to_magnitude_string(magnitude, decimal_points)
      result.sub("£-", "-£")
    end
  end
end