$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'fixturized'
require 'rspec'
require 'mocha'

TEMP_DIR = File.join(File.dirname(__FILE__),'..','temp')
TEMP_FIXTURE_DIR = File.join(TEMP_DIR,'fixtures')

RSpec.configure do |config|
   config.mock_with :mocha
end

def remove_temp_dir
  if Dir[TEMP_DIR]
    FileUtils.rm_rf TEMP_DIR
  end
end
