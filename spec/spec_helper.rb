require 'simplecov'
SimpleCov.start do
  add_filter ".bundle"
end

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'fixturized'
require 'rspec'
require 'mocha'

RSpec.configure do |config|
   config.mock_with :mocha
end

def scenario(*args, &block)
  it(*args, &block)
end
