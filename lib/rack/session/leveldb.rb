require 'rack/session/abstract/id'
require 'leveldb'

module Rack
  module Session
    class LevelDB < Abstract::ID
      attr_reader :mutex, :pool

      DEFAULT_OPTIONS = Abstract::ID::DEFAULT_OPTIONS.merge :drop => false

      def initialize(app, options={})
        super
        @pool = Hash.new
        @mutex = Mutex.new
      end

      def generate_sid
        loop do
          sid = super
          break sid unless @pool.key? sid
        end
      end

      def get_session(env, sid)
        with_lock(env, [nil, {}]) do
          unless sid and session = @pool[sid]
            sid, session = generate_sid, {}
            @pool.store sid, session
          end
          [sid, session]
        end
      end

      def set_session(env, session_id, new_session, options)
        with_lock(env, false) do
          @pool.store session_id, new_session
          session_id
        end
      end

      def destroy_session(env, session_id, options)
        with_lock(env) do
          @pool.delete(session_id)
          generate_sid unless options[:drop]
        end
      end

      def with_lock(env, default=nil)
        @mutex.lock if env['rack.multithread']
        yield
      rescue
        default
      ensure
        @mutex.unlock if @mutex.locked?
      end
    end
  end
end
