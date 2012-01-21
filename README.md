rack-session-leveldb
====================

Rack session store for LevelDB

## Installation

    gem install rack-session-leveldb

## Usage

Simple (db\_path: ENV['TMP']/rack.session)

    use Rack::Session::LevelDB

Specify DB path

    use Rack::Session::LevelDB, File.dirname(__FILE__) + '/tmp/rack.session'

Set LevelDB instance

    leveldb = LevelDB::DB.new(File.dirname(__FILE__) + '/db')
    use Rack::Session::LevelDB, leveldb

Specify DB path with some config

    use Rack::Session::LevelDB, {
      :db_path      => File.dirname(__FILE__) + '/tmp/rack.session',
      :expire_after => 600
    }

Set LevelDB instance with some config

    leveldb = LevelDB::DB.new(File.dirname(__FILE__) + '/db')
    use Rack::Session::LevelDB, {
      :cache        => leveldb,
      :cleanup      => false,
      :expire_after => 600
    }


