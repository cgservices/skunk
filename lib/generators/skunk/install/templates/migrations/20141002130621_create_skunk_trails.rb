class CreateSkunkTrails < ActiveRecord::Migration
  def change
    create_table :skunk_trails do |t|
      t.datetime :starts_at
      t.datetime :middleware_finish_at
      t.float    :elapsed_time_in_middleware
      t.datetime :request_finish_at
      t.float    :elapsed_time
      t.string   :request_url
    end
  end
end