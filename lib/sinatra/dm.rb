
require 'sinatra/base'
require 'dm-core'
# # require 'dm-migrations'
# require 'dm-timestamps'
# require 'dm-validations'
# require 'dm-serializer'
# require 'dm-types'

module Sinatra
  
  # Sinatra DataMapperExtension module
  # 
  #  TODO:: Need to write documentation here 
  # 
  module DataMapperExtension 
    
    VERSION = '0.1.1' unless const_defined?(:VERSION)
    def self.version; "Sinatra::DataMapperExtension v#{VERSION}"; end
    
    module Helpers 
      
      ##
      # TODO: add some comments here
      #  
      # ==== Examples
      # 
      # 
      # @api public
      def database
        options.database
      end
      
    end #/ Helpers
    
    
    ##
    # TODO: add some comments here
    #  
    # ==== Examples
    # 
    # 
    # @api public
    def database=(url, context = :default)
      # NOTE:: see note below in :database method 
      # @database = nil  
      set :dm_setup_context, context
      set :database_url, url
      puts "-- Initiated DataMapper DB [#{database_url.sub(::APP_ROOT, '...')}]"
      database_logger
      database
    end
    
    ##
    # TODO: add some comments here
    #  
    # ==== Examples
    # 
    # 
    # @api public
    def database
      # NOTE:: Having an instance variable here, causes problems
      # when having two Sinatra Apps, each with their own db setup.
      # the instance variable retains only the last setup, so the
      # first setup is overwritten.
      database ||= ::DataMapper.setup(dm_setup_context, database_url)
    end
    
    
    ##
    # TODO: add some comments here
    #  
    # ==== Examples
    # 
    # 
    # @api public
    def database_logger
      @database_logger ||= ::DataMapper::Logger.new(dm_logger_path, dm_logger_level)
    end
    
    ## TODO: Should support real migrations, 
    
    ##
    # TODO: add some comments here
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
    # TODO: add some comments here
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
    
  protected
    
    
    # ##
    # # TODO: add some comments here
    # #  
    # # ==== Examples
    # # 
    # # 
    # # @api public
    # def create_migrations_table
    #   database.create_table? :migrations do
    #     primary_key :id
    #     text :name, :null => false, :index => true
    #     timestamp :ran_at
    #   end
    # end
    
    
    def self.registered(app)
      app.set :dm_logger_level, :debug
      app.set :dm_logger_path, lambda { "#{::APP_ROOT}/log/dm.#{environment}.log" }
      app.set :dm_setup_context, :default
      app.set :database_url, lambda { ENV['DATABASE_URL'] || "sqlite3://#{::APP_ROOT}/db/#{environment}.db" }
      
      # app.set :migrations_table_name, :migrations
      # app.set :migrations_log, lambda { STDOUT }
      
      app.helpers DataMapperExtension::Helpers
      
      ## add the extension specific options to those inspectable by :options_inspect method
      %w( dm_logger_path dm_logger_level database_url 
      dm_setup_context database ).each do |m|
        app.sinatra_options_for_inspection << m
      end
      
      # QUESTION:: Should this actually be here? 
      # or should I just use the rake tasks
      # 
      if app.development?
        app.get '/install/db/bootstrap' do 
          out = ""
          Dir["#{::APP_ROOT}/db/bootstraps/*.sql"].each do |b|
            db = self.class.database_url.sub('sqlite3://','')
            `sqlite3 #{db} < #{b}`
            out << "\t\t<li> -- #{b.sub(::APP_ROOT,'..')} loaded</li>\n"
          end
          
          html = %Q[<div id="main-content">\n]
          html << %Q[\t<h2>Install :: Database Bootstrapping</h2>\n]
          html << %Q[\t<p>Loading bootstraps from [ #{::APP_ROOT}/db/bootstraps/ ]</p>\n]
          html << %Q[\t<ul>\n]
          html << out
          html << %Q[\t</ul>\n]
          html << %Q[\t<p>Bootstrapping finished.</p>\n]
          html << %Q[\t<p><a href="javascript:history.go(-1);">Go Back</a></p>\n]
          html << %Q[</div>\n]
          
          erb(html)
        end
      end
      
    end #/ self.registered
    
  end #/ DataMapperExtension
  
  register(Sinatra::DataMapperExtension)
  
end #/ Sinatra