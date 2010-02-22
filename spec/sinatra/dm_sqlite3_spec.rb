
require File.expand_path(File.dirname(__FILE__) + '../../spec_helper')

describe "Sinatra" do 
  
  describe "DM" do 
    
    describe "when using a SQLite3 db" do 
      
      describe "and using Default Settings" do 
        
        class MyTestApp < Sinatra::Base 
          register(Sinatra::DataMapperExtension)
          
          # need to set this for the logger to function
          set :environment, ENV['RACK_ENV'].to_sym || :test
          
          # NOTE:: The database configuration must be set 
          # in order for the DataMapper.auto_migrate! /auto_upgrade! migrations work
          set :database, dm_database_url
          
          ## ROUTES TEST (IF DATA COMES THROUGH)
          get '/db-default' do
            Post.all.map(&:name).join(', ') # Post1, Post2,...
          end
          
        end
        
        before(:each) do 
          class ::Test::Unit::TestCase 
            def app; ::MyTestApp.new ; end
          end
          @app = app
          
          dm_bootstrap('SQLite3-Default')  ## INIT THE TABLES AND LOAD THE DATA
        end
        
        after(:each) do 
          class ::Test::Unit::TestCase 
            def app; nil ; end
          end
          @app = nil
        end
        
        describe "Configuration" do 
          
          it "should set :db_dir to ../db" do 
            MyTestApp.db_dir.should == "#{fixtures_path}/db"
          end
          
          it "should set :dm_logger_level to :debug" do 
            MyTestApp.dm_logger_level.should == :debug
          end
          
          it "should set :dm_logger_path to [../log/dm.< environment >.log]" do 
            MyTestApp.dm_logger_path.should == "#{fixtures_path}/log/dm.test.log"
          end
          
          it "should set :dm_setup_context to :default" do 
            MyTestApp.dm_setup_context.should == :default
          end
          
          it "should set :dm_database_url to [../db/db.< environment >.db]" do 
            MyTestApp.dm_database_url.should == "sqlite3://#{fixtures_path}/db/db.test.db"
          end
          
        end #/ Configuration 
        
        describe "Helpers" do 
          
          describe "#database" do 
            
            it "should return an SQLite3 Adapter" do 
              app.database.should be_a_kind_of(DataMapper::Adapters::Sqlite3Adapter)
            end
            
            it "should be configured with the correct DB path [../db/db.< environment >.db]" do 
              app.database.options['path'].should == "#{fixtures_path}/db/db.test.db"
            end
            
            it "should be configured with the correct setup [:default]" do 
              app.database.name.should == :default
            end
            
          end #/ #database
          
          describe "#db_logger" do 
            
            it "should be a DataMapper::Logger Object" do 
              app.db_logger.should be_a_kind_of(DataMapper::Logger)
            end
            
            it "should have the correct log path [../log/dm.< environment >.log]" do 
              app.db_logger.init_args[0].should == "#{fixtures_path}/log/dm.test.log"
            end
            
            it "should have the correct log level [:debug]" do 
              app.db_logger.init_args[1].should == :debug
            end
            
            it "should write log messages to the log file" do 
              custom_message = "__DEBUG_DEFAULT_MESSAGE__ written at [#{Time.now.strftime("%Y-%m-%d %H:%M:%S")}]"
              app.db_logger.debug(custom_message)
              IO.read(app.db_logger.init_args[0]).should match(/#{Regexp.escape(custom_message)}/)
            end
            
          end #/ #db_logger
          
        end #/ Helpers
        
        
        describe "DB Queries" do 
          
          it "should return the data from the database" do 
            get("/db-default")
            body.should == "SQLite3-DefaultPost1, SQLite3-DefaultPost2, SQLite3-DefaultPost3" 
          end
          
        end #/ DB Queries
        
      end #/ and using Default Settings
      
      
      describe "and using Custom Settings" do 
        
        class MyCustomTestApp < Sinatra::Base 
          register(Sinatra::DataMapperExtension)
          
          # NOTE:: :dm_logger_level & :dm_logger_path must be set before :database 
          # in order to use custom settings
          set :db_dir, "#{fixtures_path}/db/custom"
          set :dm_logger_level, :info
          set :dm_logger_path, "#{fixtures_path}/log/dm.my_custom_test_app.log"
          set :dm_setup_context, :custom
          set :dm_database_url, lambda { "sqlite3://#{db_dir}/db.my_custom_test_app.db" }
          
          # NOTE:: The database configuration must be set 
          # in order for the DataMapper.auto_migrate! /auto_upgrade! migrations work
          set :database, dm_database_url
          
          ## ROUTES TEST (IF DATA COMES THROUGH)
          get '/db-custom' do
            Post.all.map(&:name).join(', ') # Post1, Post2,...
          end
          
        end
        
        before(:each) do 
          class ::Test::Unit::TestCase 
            def app; ::MyCustomTestApp.new ; end
          end
          @app = app
          
          dm_bootstrap('SQLite3-Custom')  ## INIT THE TABLES AND LOAD THE DATA
        end
        
        after(:each) do 
          class ::Test::Unit::TestCase 
            def app; nil ; end
          end
          @app = nil
        end
        
        describe "Configurations" do 
          
          it "should set :db_dir to ../db/custom" do 
            MyCustomTestApp.db_dir.should == "#{fixtures_path}/db/custom"
          end
          
          it "should set :dm_logger_level to :info" do 
            MyCustomTestApp.dm_logger_level.should == :info
          end
          
          it "should set :dm_logger_path to [../log/dm.my_custom_test_app.log]" do 
            MyCustomTestApp.dm_logger_path.should == "#{fixtures_path}/log/dm.my_custom_test_app.log"
          end
          
          it "should set :dm_setup_context to :custom" do 
            MyCustomTestApp.dm_setup_context.should == :custom
          end
          
          it "should set :dm_database_url to [../db/db.my_custom_test_app.db]" do 
            MyCustomTestApp.dm_database_url.should == "sqlite3://#{fixtures_path}/db/custom/db.my_custom_test_app.db"
          end
          
        end #/ Configurations
        
        
        describe "Helper method " do 
          
          describe "#database" do 
            
            it "should return an SQLite3 Adapter" do 
              app.database.should be_a_kind_of(DataMapper::Adapters::Sqlite3Adapter)
            end
            
            it "should be configured with the correct DB path [../db/db.my_custom_test_app.db]" do 
              app.database.options['path'].should == "#{fixtures_path}/db/custom/db.my_custom_test_app.db"
            end
            
            it "should be configured with the correct setup [:custom]" do 
              app.database.name.should == :custom
            end
            
          end #/ #database
          
          describe "#db_logger" do 
            
            it "should be a DataMapper::Logger Object" do 
              app.db_logger.should be_a_kind_of(DataMapper::Logger)
            end
            
            it "should have the correct log path [../log/dm.my_custom_test_app.log]" do 
              app.db_logger.init_args[0].should == "#{fixtures_path}/log/dm.my_custom_test_app.log"
            end
            
            it "should have the correct log level [:info]" do 
              app.db_logger.init_args[1].should == :info
            end
            
            it "should write log messages to the log file" do 
              custom_message = "__INFO_CUSTOM_MESSAGE__ written at [#{Time.now.strftime("%Y-%m-%d %H:%M:%S")}]"
              app.db_logger.info(custom_message)
              IO.read(app.db_logger.init_args[0]).should match(/#{Regexp.escape(custom_message)}/)
            end
            
            it "should NOT write debug log messages to the log file" do 
              custom_message = "__DEBUG_CUSTOM_MESSAGE__ written at [#{Time.now.strftime("%Y-%m-%d %H:%M:%S")}]"
              app.db_logger.debug(custom_message)
              IO.read(app.db_logger.init_args[0]).should_not match(/#{Regexp.escape(custom_message)}/)
            end
            
          end #/ #db_logger
          
        end #/ Helper method 
        
        
        describe "DB Queries" do 
          
          it "should return the data from the database" do 
            get("/db-custom")
            body.should == "SQLite3-CustomPost1, SQLite3-CustomPost2, SQLite3-CustomPost3" 
          end
          
        end #/ DB Queries
        
      end #/ and using Custom Settings
      
    end #/ when using a SQLite3 db
  end #/ DM
end #/ Sinatra