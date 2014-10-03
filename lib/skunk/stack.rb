module ActionDispatch
  class MiddlewareStack

    # this class will wrap around each Rack-based middleware and take timing snapshots of how long
    # each middleware takes to execute
    class Skunk

      LogThreshold = 2000 # miliseconds

      def initialize(app)
        @app = app
      end

      def call(env)
        env = incoming_timestamp(env)
        status, headers, body = @app.call env
        env = outgoing_timestamp(env)
        close_timestamp(env) if status == '301'
        [status, headers, body]
      end

      def incoming_timestamp(env)
        start_time = Time.now.utc
        unless env.has_key?("SKUNK_TRAIL_TIMESTAMP")
          unless env['REQUEST_URI'] =~ /\/assets\// || env['REQUEST_URI'] =~ /\/spree\//
            skunk_trail = ::Skunk::SkunkTrail.create( starts_at: start_time,
                                                      request_url: env['REQUEST_URI'])
            env["SKUNK_TRAIL_ID"] = skunk_trail.id
            env["SKUNK_TRAIL_START_TIMESTAMP"] = start_time
          end
        end
        env["SKUNK_TRAIL_TIMESTAMP"] = [@app.class.to_s, start_time]
        env
      end

      def outgoing_timestamp(env)
        if env.has_key?("SKUNK_TRAIL_TIMESTAMP") && env["SKUNK_TRAIL_ID"].present? && env["SKUNK_TRAIL_START_TIMESTAMP"].present?
          elapsed_time = (Time.now.utc.to_f - env["SKUNK_TRAIL_START_TIMESTAMP"].to_f) * 1000
          if env["SKUNK_TRAIL_TIMESTAMP"][0] && env["SKUNK_TRAIL_TIMESTAMP"][0] == @app.class.to_s
            if ::Skunk.log_middleware_time
              # this is the actual elapsed time of the final piece of Middleware (typically routing) AND the actual application's action
              ::ActiveRecord::Base.connection.execute("UPDATE skunk_trails SET middleware_finish_at='#{Time.now.utc.to_s(:db)}', elapsed_time_in_middleware=#{elapsed_time}  WHERE id=#{env["SKUNK_TRAIL_ID"]}")
            end
          end
        end
        env["SKUNK_TRAIL_TIMESTAMP"] = [nil, Time.now.utc]
        env
      end

      def close_timestamp(env)
        elapsed_time = (Time.now.utc.to_f - env["SKUNK_TRAIL_START_TIMESTAMP"].to_f) * 1000
        if elapsed_time > ::Skunk.log_threshold
          ::ActiveRecord::Base.connection.execute("UPDATE skunk_trails SET request_finish_at='#{Time.now.utc.to_s(:db)}', elapsed_time=#{elapsed_time} WHERE id=#{env["SKUNK_TRAIL_ID"]}")
        else
          ::ActiveRecord::Base.connection.execute("DELETE FROM skunk_trails WHERE id=#{env["SKUNK_TRAIL_ID"]}")
        end
      end
    end

    class Middleware

      # overrding the built-in Middleware.build and adding a RackTimer wrapper class
      def build(app)
        Skunk.new(klass.new(app, *args, &block))
      end

    end

    # overriding this in order to wrap the incoming app in a Skunk, which gives us timing on the final
    # piece of Middleware, which for Rails is the routing plus the actual Application action
    def build(app = nil, &block)
      app ||= block
      raise "MiddlewareStack#build requires an app" unless app
      to_a.reverse.inject(Skunk.new(app)) { |a, e| e.build(a) }
    end

  end
end