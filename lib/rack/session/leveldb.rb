require 'rack/session/abstract/id'
require 'leveldb'
module Rack
  module Session
    class LevelDB < Abstract::ID
      attr_reader :mutex, :pool

      DEFAULT_OPTIONS = Abstract::ID::DEFAULT_OPTIONS.merge \
        :namespace => 'rack.session:',
        :db_path  => '/tmp/rack.session-leveldb'

      def initialize(app, options={})
        super
        @pool = ::LevelDB::DB.new @default_options[:db_path]
        @mutex = Mutex.new
      end

      def generate_sid
        loop do
          sid = super
          break sid unless @pool.exists? sid
        end
      end

      def get_session(env, sid)
        with_lock(env, [nil, {}]) do
          unless sid and session = _get(sid)
            sid, session = generate_sid, {}
            _put sid, session
          end
          [sid, session]
        end
      end

      def set_session(env, session_id, new_session, options)
        with_lock(env, false) do
          _put session_id, new_session
          session_id
        end
      end

      def destroy_session(env, session_id, options)
        with_lock(env) do
          _delete(session_id)
          generate_sid unless options[:drop]
        end
      end

      def with_lock(env, default=nil)
        @mutex.lock if env['rack.multithread']
        yield
      rescue
        warn "#{self} is unable to find memcached server."
        warn $!.inspect
        default
      ensure
        @mutex.unlock if @mutex.locked?
      end

    private
      def _put(sid, session)
        @pool.put("#{@default_options[:namespace]}#{sid}", Marshal.dump(session))
      end

      def _get(sid)
        Marshal.load(@pool.get("#{@default_options[:namespace]}#{sid}")) rescue nil
      end

      def _delete(sid)
        @pool.delete("#{@default_options[:namespace]}#{sid}")
      end
    end
  end
end
