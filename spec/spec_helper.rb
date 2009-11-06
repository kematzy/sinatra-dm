
::APP_ROOT = File.join(File.dirname(__FILE__), 'fixtures') 

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'rubygems'
require 'sinatra/dm'
require 'sinatra/tests'

require 'dm-core'


Spec::Runner.configure do |config|
  config.include RspecHpricotMatchers
  config.include Sinatra::Tests::TestCase
  config.include Sinatra::Tests::SharedSpecs
end

def fixtures_path 
  "#{File.dirname(File.expand_path(__FILE__))}/fixtures"
end


class MyTestApp < Sinatra::Base
  
  register(Sinatra::DataMapperExtension)
  
  set :environment, :test
  # set :dm_logger_level, :info
  
  # NOTE:: The database configuration must be set 
  # in order for the DataMapper.auto_migrate! /auto_upgrade! migrations work
  
  set :database, "sqlite3://#{APP_ROOT}/db/db.test.db"
  
  # ::DataMapper.auto_migrate!
  
  
  ## LOAD MODELS
  require "dm_model.rb"
  
  ## Migrate only in test environments, else upgrade
  # test? ? ::DataMapper.auto_migrate! : ::DataMapper.auto_upgrade!
  
  
  
  ## ROUTES TEST (IF DATA COMES THROUGH)
  get '/db' do
    @posts = Post.all
    out = []
    @posts.each { |p| out << p.name }
    # out = @posts.map { |p| p.name }
    out.join(', ')
  end
  
end

def dm_bootstrap
  
  # DataMapper.setup :default, "sqlite3://#{APP_ROOT}/db/db.bootstrap.db"  
  # Post.auto_upgrade!
  # ::DataMapper::Migrations.auto_upgrade!
  
end