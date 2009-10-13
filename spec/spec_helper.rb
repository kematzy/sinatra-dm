$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'sinatra/dm'
require 'spec'
require 'spec/autorun'
# require 'spec/interop/test'

Spec::Runner.configure do |config|
  
end

def fixtures_path 
  "#{File.dirname(File.expand_path(__FILE__))}/fixtures"
end
