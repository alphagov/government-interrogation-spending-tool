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
    TablePageNode.slugify(s)
  end

  def self.slugify(s)
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

  def is_department
    @options.has_key?(:is_department) ? @options[:is_department] : false
  end

  def alternative_title_or_title
    @options.has_key?(:alternative_title) ? @options[:alternative_title] : @title
  end

  def to_s
    "TablePageNode: title = #{title}, total = #{total.to_s}, slug = #{slug}, children = #{children.to_s}"
  end
end