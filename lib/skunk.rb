require 'action_dispatch'
require 'active_record'
require 'skunk/skunk_trail'

module Skunk
  require 'skunk/stack'

  mattr_accessor :log_threshold, :log_middleware_time

  def log_threshold
    @@log_threshold || 0
  end

  def log_middleware_time
    @@log_middleware_time || true
  end
end
