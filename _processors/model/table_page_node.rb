# encoding: utf-8

class TablePageNode

  attr_accessor :slug,
                :title,
                :total,
                :children,
                :options

  def initialize title, total, children = [], slug = nil, options = {}
      @title = title
      @total = total
      @children = children
      @slug = slug.nil? ? slugify(title) : slugify(slug)
      @options = options
  end

  def slugify(s)
    slug = s.strip.downcase
    slug.gsub! /['`]/,""
    slug.gsub! /\s*@\s*/, " at "
    slug.gsub! /\s*&\s*/, " and "
    slug.gsub! /\s*[^A-Za-z0-9\.\-]\s*/, '-'
    slug.gsub! /-+/,"-"
    slug.gsub! /\A[-\.]+|[-\.]+\z/,""

    slug
  end

  def has_children
    !children.nil? && !children.empty?
  end

  def is_quarter
    @options.has_key?(:is_quarter) ? @options[:is_quarter] : false
  end

  def to_s
    "TablePageNode: title = #{title}, total = #{total.to_s}, slug = #{slug}, children = #{children.to_s}"
  end
end