# encoding: utf-8

class TablePageNode

  attr_accessor :slug,
                :title,
                :total,
                :children

  def initialize title, total, children = [], slug = nil
      @title = title
      @total = total
      @children = children
      @slug = slug.nil? ? slugify(title) : slugify(slug)
  end

  def slugify(s)
    slug = s.strip.downcase
    slug.gsub! /['`]/,""
    slug.gsub! /\s*@\s*/, " at "
    slug.gsub! /\s*&\s*/, " and "
    slug.gsub! /\s*[^A-Za-z0-9\.\-]\s*/, '_'
    slug.gsub! /_+/,"_"
    slug.gsub! /\A[_\.]+|[_\.]+\z/,""

    slug
  end

  def has_children
    !children.nil? && !children.empty?
  end
end