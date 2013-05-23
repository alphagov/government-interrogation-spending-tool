# encoding: utf-8
require "fileutils"

class TablePageGenerator
  attr_accessor :root_directory_path
  def initialize root_directory_path
    @root_directory_path = root_directory_path
  end

  def delete_existing_files
    FileUtils.rm_rf Dir.glob("#{@root_directory_path}/*"), :secure => true
  end
end