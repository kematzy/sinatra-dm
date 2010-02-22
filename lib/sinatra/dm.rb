
require 'sinatra/base'
require 'dm-core'

module Sinatra
  
  # = Sinatra DataMapperExtension module
  # 
  # A Sinatra Extension that makes working with DataMapper easier.
  # 
  # 
  # == Installation
  # 
  #   #  Add Gemcutter to your RubyGems sources 
  #   $  gem sources -a http://gemcutter.com
  # 
  #   $  (sudo)? gem install sinatra-dm
  # 
  # == Dependencies
  # 
  # This Gem depends upon the following:
  # 
  # === Runtime:
  # 
  # * sinatra ( >= 0.10.1 )
  # * dm-core ( >= 0.10.1 )
  # 
  # And a constant named ::APP_ROOT defined in your App, pointing to the root of your app.
  # 
  #   # set the root of the whole app
  #   APP_ROOT = Dir.pwd
  # 
  # === Development & Tests:
  # 
  # * rspec (>= 1.2.7 )
  # * rack-test (>= 0.4.1)
  # * rspec_hpricot_matchers (>= 0.1.0)
  # * sinatra-tests (>= 0.1.5)
  # 
  # === Optional:
  # 
  # * kematzy-tasks (>= 0.1.5) # handy Rake tasks for working with SQLite3 DB's
  # 
  # 
  # == Getting Started
  # 
  # In your Sinatra app code base, 
  # 
  #   require 'sinatra/dm'
  # 
  # then in your App declaration,
  # 
  # 
  #   class YourApp < Sinatra::Base 
  #     register(Sinatra::DataMapperExtension)  # NOTE:: the extension name
  # 
  #     # NOTE:: need to ensure this is set this for the logger to function
  #     set :environment, ENV['RACK_ENV'].to_sym || :test
  # 
  #     # NOTE:: The database configuration must be set so 
  #     # the DataMapper.auto_migrate! / .auto_upgrade! migrations work
  #     set :database, dm_database_url
  # 
  #     ## ROUTES 
  #     get '/posts' do
  #       @posts = Post.all
  #     end
  # 
  #   end
  # 
  # Most of the above is obvious, but this line...
  # 
  #   set :database, dm_database_url
  # 
  # ...is perhaps a bit confusing, so let's clarify it.
  # 
  # <tt>#dm_database_url</tt> is an Extension setting - (see below) - that contains the whole
  # SQLite3 DSN string.
  # 
  #   "sqlite3:///path/2/your/app/root/db/db.test.db"
  # 
  # 
  # In real terms, you could just as well have written this:
  # 
  #   set :database, "sqlite3:///path/2/your/app/root/db/db.test.db"
  # 
  # or
  # 
  #   set :database, "mysql://username:password@dbhost/db_name"
  # 
  #   # if you have MySQL set up **insecurely** on your local workstation
  #   set :database, "mysql://root:@dbhost/db_name"
  # 
  # 
  # 
  # == Configuration Options 
  # 
  # The following options are available for you to configure your DataMapper setup
  # 
  # * <tt>:db_dir</tt> -- sets the path to where your SQLite3 DBs should be.
  #   (Default: [/full/path/2/your/app/db] )
  # 
  # * <tt>:dm_logger_level</tt> -- sets the level at which DataMapper.Logger should log.
  #   (Default: [:debug] )
  # 
  # * <tt>:dm_logger_path</tt> -- sets the path to the log file where DataMapper.Logger should log.
  #   (Default: [/full/path/2/your/app/log/dm.{environment}.log] )
  # 
  # * <tt>:dm_setup_context</tt> -- sets the DataMapper Setup context.
  #   (Default: [:default] )
  # 
  # * <tt>:dm_database_url</tt> -- sets the DSN.
  #   (Default: ENV['DATABASE_URL'] || "sqlite3://#{db_dir}/db.#{environment}.db" )
  # 
  # 
  # There are many ways in which you can use the above configurations in YourApp. 
  # 
  # Here are a few examples:
  # 
  #   class YourApp < Sinatra::Base
  #     register(Sinatra::DataMapperExtension)  # NOTE:: the extension name
  #     
  #     <snip...>
  #     
  #     # set the db path to outside of your app root
  #     set :db_dir, "/home/USERNAME/SQLite3-dbs/"
  #     
  #     # to only log :warn and above
  #     set :dm_logger_level, :warn
  #     
  #     # set the path to your log files outside of your app root
  #     set :dm_logger_path, "/var/log/dm.your_app.log"
  #     
  #     # use a different Setup context than :default
  #     set :dm_setup_context, :custom
  #     
  #     <snip...>
  #     
  #     # NB! Don't forget to set the database configuration
  #     set :database, dm_database_url
  #     
  #   end
  # 
  # 
  # 
  module DataMapperExtension 
    
    VERSION = '0.1.3' unless const_defined?(:VERSION)
    def self.version; "Sinatra::DataMapperExtension v#{VERSION}"; end
    
    module Helpers 
      
      ##
      # Access to the database settings, should you need them
      # within your app
      #  
      # ==== Examples
      # 
      #   if database.name == :default
      #     # do something...
      # 
      #   
      # 
      # @api public
      def database 
        settings.database
      end
      
      ##
      # Handy alias to the DataMapper logger
      #  
      # ==== Examples
      # 
      #   db_logger.info("message")
      #   
      # 
      # @api public/private
      def db_logger
        self.class.database_logger
      end
      
    end #/ Helpers
    
    
    ##
    # Sets the Database DSN connection, and setup name.
    #  
    # ==== Examples
    #   
    #   # Default usage is via the set :database setting
    #   
    #   set :database, "sqlite3:///path/2/your/app/db/test.db"
    #   
    # 
    # But you can also set the db connection on your App directly via this as a class method
    # 
    #   YourApp.database = "sqlite3:///path/2/your/app/db/test.db", :custom_setup_name
    # 
    # 
    # @api public
    def database=(*args) 
      if args.first.is_a?(Array)
        reset_db = true
        url = args.first[0]
        context = args.first[1] || dm_setup_context || :default
      else
        url = args.first
        context = dm_setup_context || :default
      end
      set :dm_setup_context, context
      set :dm_database_url, url
      db_type = dm_database_url.split('://').first
      db_url = dm_database_url.sub(::APP_ROOT, '').sub("#{db_type}://",'')
      puts "-- - activated DataMapper #{db_type.capitalize} Database at [ #{db_url} ]"
      database_reset if reset_db
      database_logger
      database
    end
    
    ##
    # Provides access to your database setup
    #  
    # ==== Examples
    # 
    #   YourApp.database  => returns the whole DataMapper db setup 
    # 
    # 
    # @api public
    def database 
      # NOTE:: Having an instance variable here, causes problems
      # when having two Sinatra Apps, each with their own db setup.
      # the instance variable retains only the last setup, so the
      # first setup is overwritten.
      @database ||= ::DataMapper.setup(dm_setup_context, dm_database_url)
    end
    
    ##
    # Resets the current DB setup and connection
    #  
    # ==== Examples
    # 
    # 
    # @api private
    def database_reset
      @database = nil
    end
    
    ##
    # Sets up the DataMapper::Logger instance, caches it and returns it
    #  
    # ==== Examples
    #   
    #   YourApp.database_logger.debug("Message") => log's message in the log
    # 
    # 
    # @api public
    def database_logger 
      # NOTE:: Having an instance variable here, causes problems
      # when having two Sinatra Apps, each with their own db setup.
      # the instance variable retains only the last setup, so the
      # first setup is overwritten.
      @database_logger ||= ::DataMapper::Logger.new(dm_logger_path, dm_logger_level)
    end
    
    # :nodoc:
    
    ## TODO: Should support real migrations, 
    
    ##
    # TODO: implement this functionality
    #  
    # ==== Examples
    # 
    # 
    # @api public
    # def database_migrate!(type = :upgrade)
    #   case type
    #   when :migrate
    #     ::DataMapper.auto_upgrade!
    #   else
    #     ::DataMapper.auto_upgrade!
    #   end
    # end
    
    ##
    # TODO: implement this functionality
    #  
    # ==== Examples
    # 
    # 
    # @api public
    # def migration(name, &block)
    #   create_migrations_table
    #   return if database[:migrations].filter(:name => name).count > 0
    #   migrations_log.puts "Running migration: #{name}"
    #   database.transaction do
    #     yield database
    #     database[migrations_table_name] << { :name => name, :ran_at => Time.now }
    #   end
    # end
    
    # %w(mysql sqlite3 postgres oracle yaml).each do |adapter|
    #   define_method("#{adapter}?") { @database.options['adapter'] == adapter } 
    # end
    
    # :doc:
    
  protected
    
    def self.registered(app)
      app.set :db_dir, "#{::APP_ROOT}/db"
      app.set :dm_logger_level, :debug
      app.set :dm_logger_path, lambda { "#{::APP_ROOT}/log/dm.#{environment}.log" }
      app.set :dm_setup_context, :default
      app.set :dm_database_url, lambda { ENV['DATABASE_URL'] || "sqlite3://#{db_dir}/db.#{environment}.db" }
      
      # app.set :migrations_table_name, :migrations
      # app.set :migrations_log, lambda { STDOUT }
      
      app.helpers DataMapperExtension::Helpers
      
      ## add the extension specific options to those inspectable by :options_inspect method
      if app.respond_to?(:sinatra_options_for_inspection)
        %w( db_dir dm_logger_path dm_logger_level dm_database_url 
        dm_setup_context database ).each do |m|
          app.sinatra_options_for_inspection << m
        end
      end
      
    end #/ self.registered
    
  end #/ DataMapperExtension
  
  # register(Sinatra::DataMapperExtension)
  
end #/ Sinatra