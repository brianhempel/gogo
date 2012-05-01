# autocomplete commands
# thanks to http://bogojoker.com/readline/
# and to https://github.com/ruby/ruby/blob/trunk/ext/readline/readline.c
AUTOCOMPLETE_COMMANDS = ['rake ', 'cucumber features/', 'rails ', 'rspec spec/'].sort
RAKE_COMMANDS = ['db', 'db:migrate', 'db:test:prepare', 'db:rollback', 'routes', 'sunspot:reindex', 'sunspot:solr:start', 'sunspot:solr:start', 'sunspot:solr:stop', 'assets:clean', 'assets:precompile']

Jumpstart.preload do
  if ARGV[0]
    ENV['RAILS_ENV'] = %w{development test production staging}.find { |e| e[0] == ARGV[0][0] } || ARGV[0]
  else
    ENV['RAILS_ENV'] = ENV['JUMPSTART_ENV'] || 'test'
  end
  # need JUMPSTART_ENV for the history file
  ENV['JUMPSTART_ENV'] = ENV['RAILS_ENV']

  load_time = Benchmark.realtime do
    print "Loading application.rb..."
    require File.expand_path('./config/application', Dir.pwd)

    # we'll use class reloading
    # thanks to spork for lots of direction here
    # https://github.com/sporkrb/spork-rails/blob/master/lib/spork/app_framework/rails.rb
    # https://github.com/sporkrb/spork-rails/blob/master/lib/spork/ext/rails-reloader.rb
    Rails::Engine.class_eval do
      def eager_load!
        railties.all(&:eager_load!) if defined?(railties)
        # but don't eager load the eager_load_paths
      end
    end
    print "and environment.rb..."
    require File.expand_path('./config/environment', Dir.pwd)
    ActiveSupport::Dependencies.mechanism = :load

    if Rails.env.test?
      print "and cucumber..."
      require 'rspec'
      begin
        require 'cucumber' # saves 0.4 seconds when running cucumber

        # load everything that appears in test env.rb
        # this shaves off another 2 seconds
        # even though most of the loads technically fail
        ENV['RAILS_ROOT'] = Dir.pwd
        other_paths = File.read(Dir.pwd + "/features/support/env.rb").scan(/^require ['"](.+?)['"](?!.*jumpstart: skip)/).flatten
        other_paths.each do |path|
          print "and #{path}..."
          begin
            # load in annoymous modules so, basically, we're just cache-warming
            load(path + '.rb', true)
          rescue
          end
        end
      rescue LoadError
      end
    end

    print "and rake..."
    require 'rake'
  end

  puts "took %.2f seconds." % load_time
end

Jumpstart.command_filter do |given_command|
  # running just "rails" does an exec which reloads everything and defeats the point of preloading
  given_command == 'rails' ? './script/rails' : given_command
end

Jumpstart.before_each_ruby_command do |given_command, arguments|
  if given_command =~ /^(cucumber|rspec)$/ && ENV['RAILS_ENV'] != 'test'
    STDERR.puts "Don't run your tests when not in the test environment!"
    exit 1
  end

  # reload classes
  if defined?(ActionDispatch::Reloader)
    # Rails 3.1
    ActionDispatch::Reloader.cleanup!
    ActionDispatch::Reloader.prepare!
  else
    # Rails 3.0
    # pulled from Railties source, this triggers something
    ActionDispatch::Callbacks.new(Proc.new {}, false).call({})
    # ActiveSupport::DescendantsTracker.clear
    # ActiveSupport::Dependencies.clear

    # fix problem with ::Something::OtherThing resolving to ::OtherThing
    Rails.application.config.eager_load_paths.map { |p| Dir[p + '/**/*.rb'] }.flatten.each { |rb| require_dependency rb }
  end
end