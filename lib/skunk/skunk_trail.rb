module Skunk
  class SkunkTrail < ActiveRecord::Base
    attr_accessible :starts_at, :middleware_finish_at, :elapsed_time_in_middleware, :request_finish_at, :elapsed_time, :request_url
  end
end