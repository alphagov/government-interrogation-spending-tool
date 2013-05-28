# encoding: utf-8
class Float < Numeric
  def to_magnitude_string
    val = self.to_f
    abs = val.abs
    result = sprintf('%.1f', val)

    if    abs >= 1000000000000
      result = sprintf('%.1f', val/1000000000000) + "tn"
    elsif abs >= 1000000000
      result = sprintf('%.1f', val/1000000000) + "bn"
    elsif abs >= 1000000
      result = sprintf('%.1f', val/1000000) + "m"
    elsif abs >= 1000
      result = sprintf('%.1f', val/1000) + "k"
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
end