require 'rack/session/abstract/id'
require 'leveldb'
module Rack
  module Session
    class LevelDB < Abstract::ID
      VERSION = '0.0.1'

      attr_reader :mutex, :pool

      DEFAULT_OPTIONS = Abstract::ID::DEFAULT_OPTIONS.merge \
        :namespace => 'rack.session:',
        :db_path  => "#{ENV['TMP'] || '/tmp'}/rack.session",
        :cleanup => true

      def initialize(app, options={})
        options = {:db_path => options } if options.is_a? String
        options = {:db      => options } if options.is_a? ::LevelDB::DB
        super
        if options[:db]
          if options[:db].kind_of? ::LevelDB::DB
            @pool = options[:db]
          else
            raise ":db is not LevelDB"
          end
        else
          @pool = ::LevelDB::DB.new @default_options[:db_path]
        end

        cleanup_expired if @default_options[:cleanup]
        @mutex = Mutex.new
      end

      def generate_sid
        loop do
          sid = super
          break sid unless _exists? sid
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
        warn "#{self} is unable to open #{@default_options[:db_path]}."
        warn $!.inspect
        default
      ensure
        @mutex.unlock if @mutex.locked?
      end

      def cleanup_expired(time = Time.now)
        return unless @default_options[:expire_after]
        @pool.each do |k, v|
          if k.start_with?(@default_options[:namespace]) and
              time - Marshal.load(v)[:updated_at] > @default_options[:expire_after]
            @pool.delete(k)
          end
        end
      end

    private
      def _put(sid, session)
        @pool.put(_key(sid), Marshal.dump({:data => session, :updated_at => Time.now.utc}))
      end

      def _get(sid)
        Marshal.load(@pool.get(_key(sid)))[:data] rescue nil
      end

      def _delete(sid)
        @pool.delete(_key(sid))
      end

      def _exists?(sid)
        @pool.exists?(_key(sid))
      end

      def _key(sid)
        "#{@default_options[:namespace]}#{sid}"
      end
    end
  end
end
