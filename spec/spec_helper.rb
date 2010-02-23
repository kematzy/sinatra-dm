
::APP_ROOT = File.join(File.dirname(__FILE__), 'fixtures') 

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

#--
# DEPENDENCIES
#++
%w( 
sinatra/base 
dm-core
).each {|lib| require lib }

#--
## SINATRA EXTENSIONS
#++
%w(
sinatra/dm
sinatra/tests
).each {|ext| require ext }


ENV['RACK_ENV'] = 'test'


Spec::Runner.configure do |config|
  config.include RspecHpricotMatchers
  config.include Sinatra::Tests::TestCase
  config.include Sinatra::Tests::RSpec::SharedSpecs
end

def fixtures_path 
  "#{File.dirname(File.expand_path(__FILE__))}/fixtures"
end


# class MyTestApp < Sinatra::Base
# 
#  Declared in each test suite
# 
# end


class Test::Unit::TestCase
  include Sinatra::Tests::TestCase
  Sinatra::Base.set :environment, :test
end


### BOOTSTRAP ###

require 'dm_bootstrap.rb'
