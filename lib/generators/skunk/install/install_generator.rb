require 'rails/generators/migration'

module Skunk
  module Generators
    class InstallGenerator < ::Rails::Generators::Base
      source_root File.expand_path("../templates", __FILE__)

      def copy_migrations
        Dir["#{self.class.source_root}/migrations/*.rb"].sort.each do |filepath|
          name = File.basename(filepath)
          template "migrations/#{name}", "db/migrate/#{name}"
          sleep 1
        end
      end
    end
  end
end
