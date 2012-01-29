# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "rack-session-leveldb/version"

Gem::Specification.new do |s|
  s.name        = "rack-session-leveldb"
  s.version     = Rack::Session::LevelDB::VERSION
  s.authors     = ["Masato Igarashi"]
  s.email       = ["m@igrs.jp"]
  s.homepage    = "http://github.com/migrs/rack-session-leveldb"
  s.summary     = %q{Rack session store for LevelDB}
  s.description = %q{Rack session store for LevelDB}

  #s.rubyforge_project = "rack-session-leveldb"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  s.add_development_dependency "bacon"
  s.add_runtime_dependency "rack"
  s.add_runtime_dependency "leveldb-ruby"
end
