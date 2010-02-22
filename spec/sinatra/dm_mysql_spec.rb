
require File.expand_path(File.dirname(__FILE__) + '../../spec_helper')

describe "Sinatra" do 
  
  describe "DM" do 
    
    describe "when using a MySQL db" do 
      
      class MySQLTestApp < Sinatra::Base 
        register(Sinatra::DataMapperExtension)
        
        # NOTE:: :dm_logger_level & :dm_logger_path must be set before :database 
        # in order to use custom settings
        set :dm_logger_level, :debug
        set :dm_logger_path, "#{fixtures_path}/log/dm.mysql_test_app.log"
        
        # NB!! sets the connection to an existing db [sinatra_dm_tests]
        # in a standard install MySQL db (ie: unsecured) without a password
        set :database, 'mysql://root:@localhost/sinatra_dm_tests'
        
        ## ROUTES TEST (IF DATA COMES THROUGH)
        get '/db-mysql' do
          Post.all.map(&:name).join(', ') # Post1, Post2,...
        end
        
      end
      
      before(:each) do 
        class ::Test::Unit::TestCase 
          def app; ::MySQLTestApp.new ; end
        end
        @app = app
        
        dm_bootstrap('MySQL-Test')  ## INIT THE TABLES AND LOAD THE DATA
      end
      
      after(:each) do 
        class ::Test::Unit::TestCase 
          def app; nil ; end
        end
        @app = nil
      end
      
      describe "Configurations" do 
        
        it "should set :db_dir to [../db]  (NB! unused value when using MySQL)" do 
          MySQLTestApp.db_dir.should == "#{fixtures_path}/db"
        end
        
        it "should set :dm_logger_level to :debug" do 
          MySQLTestApp.dm_logger_level.should == :debug
        end
        
        it "should set :dm_logger_path to [../log/dm.mysql_test_app.log]" do 
          MySQLTestApp.dm_logger_path.should == "#{fixtures_path}/log/dm.mysql_test_app.log"
        end
        
        it "should set :dm_setup_context to :default" do 
          MySQLTestApp.dm_setup_context.should == :default
        end
        
        it "should set :dm_database_url to [mysql://]" do 
          MySQLTestApp.dm_database_url.should == "mysql://root:@localhost/sinatra_dm_tests"
        end
        
      end #/ Configurations
      
      
      describe "Helper method " do 
        
        describe "#database" do 
          
          it "should return an MySQL Adapter" do 
            app.database.should be_a_kind_of(DataMapper::Adapters::MysqlAdapter)
          end
          
          describe "and the MySQL Adapter " do 
            
            it "should be configured with the correct DB host [localhost]" do 
              app.database.options['host'].should == "localhost"
            end
            
            it "should be configured with the correct DB path [/sinatra_dm_tests]" do 
              app.database.options['path'].should == "/sinatra_dm_tests"
            end
            
            it "should be configured with the correct DB user [root]" do 
              app.database.options['user'].should == "root"
            end
            
            it "should be configured with the correct DB password [ (empty)]" do 
              app.database.options['password'].should == ""
            end
            
            it "should be configured with the correct setup [:default]" do 
              app.database.name.should == :default
            end
            
          end #/ and the MySQL Adapter 
          
          
        end #/ #database
        
        describe "#db_logger" do 
          
          it "should be a DataMapper::Logger Object" do 
            app.db_logger.should be_a_kind_of(DataMapper::Logger)
          end
          
          it "should have the correct log path [../log/dm.mysql_test_app.log]" do 
            app.db_logger.init_args[0].should == "#{fixtures_path}/log/dm.mysql_test_app.log"
          end
          
          it "should have the correct log level [:debug]" do 
            app.db_logger.init_args[1].should == :debug
          end
          
          it "should write log messages to the log file" do 
            custom_message = "__INFO_MYSQL_MESSAGE__ written at [#{Time.now.strftime("%Y-%m-%d %H:%M:%S")}]"
            app.db_logger.info(custom_message)
            IO.read(app.db_logger.init_args[0]).should match(/#{Regexp.escape(custom_message)}/)
          end
          
          it "should write debug log messages to the log file" do 
            custom_message = "__DEBUG_MYSQL_MESSAGE__ written at [#{Time.now.strftime("%Y-%m-%d %H:%M:%S")}]"
            app.db_logger.debug(custom_message)
            IO.read(app.db_logger.init_args[0]).should match(/#{Regexp.escape(custom_message)}/)
          end
          
        end #/ #db_logger
        
      end #/ Helper method 
      
      
      describe "DB Queries" do 
        
        it "should return the data from the database" do 
          get("/db-mysql")
          body.should == "MySQL-TestPost1, MySQL-TestPost2, MySQL-TestPost3" 
        end
        
      end #/ DB Queries
        
      
    end #/ when using a MySQL 
  end #/ DM
end #/ Sinatra