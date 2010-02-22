class ::Post
  include DataMapper::Resource
  property :id,                   Serial
  property :name,                 String
end

def dm_bootstrap(identifier='')
  
  DataMapper.auto_migrate!
  
  Post.create!(:name => "#{identifier}Post1" )
  Post.create!(:name => "#{identifier}Post2" )
  Post.create!(:name => "#{identifier}Post3" )
end
