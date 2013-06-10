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

  def self.slugify_paths_to_url(*paths)
    '/' + paths.map{ |p| TablePageNode.slugify(p) }.join('/')
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

  def redirect_url
    @options.has_key?(:redirect_url) ? @options[:redirect_url] : nil
  end

  def alternative_layout
    @options.has_key?(:alternative_layout) ? @options[:alternative_layout] : nil
  end

  def table_header_name_label
    @options.has_key?(:table_header_name_label) ? @options[:table_header_name_label] : nil
  end

  def to_s
    "TablePageNode: title = #{title}, total = #{total.to_s}, slug = #{slug}, children = #{children.to_s}"
  end
end