# Generated by jeweler
# DO NOT EDIT THIS FILE
# Instead, edit Jeweler::Tasks in Rakefile, and run `rake gemspec`
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{sinatra-dm}
  s.version = "0.1.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["kematzy"]
  s.date = %q{2009-11-06}
  s.description = %q{Sinatra Extension for working with DataMapper (another Sinatra-Sequel Rip-off)}
  s.email = %q{kematzy@gmail.com}
  s.extra_rdoc_files = [
    "LICENSE",
     "README.rdoc"
  ]
  s.files = [
    ".document",
     ".gitignore",
     "LICENSE",
     "README.rdoc",
     "Rakefile",
     "VERSION",
     "lib/sinatra/dm.rb",
     "lib/sinatra/dm/rake.rb",
     "sinatra-dm.gemspec",
     "spec/dm_model.rb",
     "spec/fixtures/db/.gitignore",
     "spec/fixtures/log/.gitignore",
     "spec/sinatra/dm_spec.rb",
     "spec/spec_helper.rb"
  ]
  s.homepage = %q{http://github.com/kematzy/sinatra-dm}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{Sinatra Extension for working with DataMapper}
  s.test_files = [
    "spec/dm_model.rb",
     "spec/sinatra/dm_spec.rb",
     "spec/spec_helper.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<sinatra>, [">= 0.10.1"])
      s.add_runtime_dependency(%q<dm-core>, [">= 0.10.1"])
      s.add_development_dependency(%q<sinatra-tests>, [">= 0.1.5"])
    else
      s.add_dependency(%q<sinatra>, [">= 0.10.1"])
      s.add_dependency(%q<dm-core>, [">= 0.10.1"])
      s.add_dependency(%q<sinatra-tests>, [">= 0.1.5"])
    end
  else
    s.add_dependency(%q<sinatra>, [">= 0.10.1"])
    s.add_dependency(%q<dm-core>, [">= 0.10.1"])
    s.add_dependency(%q<sinatra-tests>, [">= 0.1.5"])
  end
end
