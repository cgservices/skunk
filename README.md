# Skunk
Skunk wraps itself around the middleware stack to monitor the request length and writes it to db.
She leaves a skunk_trail which helps you find anything 'smelly' in your code.

This Gem requires a working app and ActiveRecord

## Installation

### In Gemfile
    gem 'skunk', :git => "git@github.com:cgservices/skunk.git"

### Bundle
    bundle install

### Copy migrations
    rails g skunk:install
## Usage
The gem uses certain defaults. To change this you can create an initializer in config/initializers with

    Skunk.log_threshold = 2000
    Skunk.log_middleware_time = true

### Total request elapsed time
To monitor the total request time you have to add the following code to your application controller

    after_filter do
      elapsed_time = (Time.now.utc.to_f - env["SKUNK_TRAIL_START_TIMESTAMP"].to_f) * 1000
      if elapsed_time > Skunk.log_threshold
        ::ActiveRecord::Base.connection.execute("UPDATE skunk_trails SET request_finish_at='#{Time.now.utc.to_s(:db)}', elapsed_time=#{elapsed_time} WHERE id=#{env["SKUNK_TRAIL_ID"]}")
      else
        ::ActiveRecord::Base.connection.execute("DELETE FROM skunk_trails WHERE id=#{env["SKUNK_TRAIL_ID"]}")
      end
    end

## TODO
- Create a descent install generator that adds the after filter to the application_controller
- Add different logging options (i.e. Redis, File)