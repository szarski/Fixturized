module Fixturized

  def self.create_fixture_dir
    Fixturized::FileHandler.create_fixture_dir
  end

end

# external requires:
require 'sourcify'
require 'digest/md5'

#internal requires:
require 'global_methods'
require 'runner'
require 'file_handler'
require 'database_handler'
require 'wrapper'
