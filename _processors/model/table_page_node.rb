# encoding: utf-8

class TablePageNode

  attr_accessor :slug,
                :title,
                :total,
                :children

  def initialize slug, title, total, children = []
      @slug = slug
      @title = title
      @total = total
      @children = children
  end

  def has_children
    !children.nil? && !children.empty?
  end
end