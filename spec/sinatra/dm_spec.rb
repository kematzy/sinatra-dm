
require File.expand_path(File.dirname(__FILE__) + '../../spec_helper')

# dm_bootstrap

describe "Sinatra" do 
  
  describe "DM" do 
    
    before(:each) do
      class ::Test::Unit::TestCase 
        def app; ::MyTestApp.new ; end
      end
      @app = app
    end
    
    after(:each) do
      class ::Test::Unit::TestCase 
        def app; nil ; end
      end
      @app = nil
    end
    
    # it_should_behave_like "MyTestApp"
          
    describe "Using Defaults" do 
      
      it "should set the correct adapter" do
        MyTestApp.database.options['adapter'].should == "sqlite3"
      end
      
      it "should set the correct db path" do
        MyTestApp.database.options['path'].should == "#{fixtures_path}/db/db.test.db"
      end
      
      it "should set the correct dm_logger_level" do
        MyTestApp.database_logger.init_args[1].should == :debug
      end
      
      it "should set the correct dm_logger_level" do
        MyTestApp.database_logger.init_args[0].should == "#{fixtures_path}/log/dm.test.log"
      end
      
      it "should return the data from the database" do
        get("/db")
        body.should == "Post1, Post2, Post3"  
      end
      
    end #/ Using Defaults
    
    describe "Using Custom Settings" do 
      
      class MySQLTestApp < Sinatra::Base 
        register(Sinatra::DataMapperExtension)
        
        # NOTE:: :dm_logger_level & :dm_logger_path must be set before :database 
        # in order to use custom settings
        set :dm_logger_level, :info
        set :dm_logger_path, "#{::APP_ROOT}/log/dm.custom.log"
        
        set :database, 'mysql://localhost/the_database_name'
      end
      
      it "should set the correct adapter" do
        MySQLTestApp.database.options['adapter'].should == "mysql"
      end
      
      it "should set the correct db path" do
        MySQLTestApp.database.options['path'].should == "/the_database_name"
      end
      
      it "should set the correct dm_logger_level" do
        MySQLTestApp.database_logger.init_args[1].should == :info
      end
      
      it "should set the correct dm_logger_level" do
        MySQLTestApp.database_logger.init_args[0].should == "#{fixtures_path}/log/dm.custom.log"
      end
      
    end #/ Using Custom Settings
    
    
  end #/ DM
end #/ Sinatra