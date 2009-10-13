class ::Post
  include DataMapper::Resource
  property :id,                   Serial
  property :name,                 String
end #/ Post

  
# Post.auto_migrate!
DataMapper.auto_migrate!


Post.create!(:name => "Post1" )
Post.create!(:name => "Post2" )
Post.create!(:name => "Post3" )