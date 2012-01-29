rack-session-leveldb
====================

Rack session store for LevelDB

<http://github.com/migrs/rack-session-leveldb>

[![Build Status](https://secure.travis-ci.org/migrs/rack-session-leveldb.png)](http://travis-ci.org/migrs/rack-session-leveldb)
[![Still Maintained](http://stillmaintained.com/migrs/rack-session-leveldb.png)](http://stillmaintained.com/migrs/rack-session-leveldb)

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

## About LevelDB

- <http://code.google.com/p/leveldb/>
- <https://github.com/wmorgan/leveldb-ruby>

## License
[rack-session-leveldb](http://github.com/migrs/rack-session-leveldb) is Copyright (c) 2012 [Masato Igarashi](http://github.com/migrs)(@[migrs](http://twitter.com/migrs)) and distributed under the [MIT license](http://www.opensource.org/licenses/mit-license).
