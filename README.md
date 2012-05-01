# GoGo

Yaknow how you're waiting for waiting for Rails to start and other people overhear you say "Go Go Go Go!" to your computer?

Install the gem:

    gem install gogo

Make sure you're in your Rails project and then run:

    $ gogo

That will launch you into a pseudo-shell with the Rails test environment reloaded. If you want to use gogo for development commands such as `rake db:seed`, `rake db:migrate`, or `rails console`, launch a separate shell and run:

    $ gogo d

Now, run some commands. Ruby scripts that load Rails should start astronomically faster.

## Sounds fishy...

It is fishy. GoGo is a hack script.

I'm sharing it with the world because it's an incredibly useful hack, but I can't guarantee any level of maintenance on my part. If stuff breaks, you're on your own to fix it. Leave your experience in the [wiki](https://github.com/brianhempel/gogo/wiki) to help others.

GoGo is a lot like [Spork](https://github.com/sporkrb/spork). GoGo preloads your rails environment. When you run a ruby command, the gogo process is forked and the command is loaded into that environment.  Here's a performance comparison for a large project:

    $ time bundle exec cucumber features/admin/dashboard.feature:0
    real  0m30.457s
    user  0m27.300s
    sys   0m2.941s
    
    $ gogo
    Creating default Gofile for Rails...
    Loading application.rb...and environment.rb...and cucumber...and cucumber/rails...and webmock/cucumber...and ruby-debug...and factory_girl/step_definitions...and email_spec...and email_spec/cucumber...and capybara/firebug...and vcr...and rake...took 26.25 seconds.
    test $ cucumber features/admin/dashboard.feature:0
    cucumber took 3.65 seconds.
    test $ cucumber features/admin/dashboard.feature:0
    cucumber took 3.58 seconds.

The advantages over Spork are:

1. No DRB weirdness
2. Easy install -- little to no modification to test environment.
3. Speeds up other rails commands: rake routes, rails g migration, rake db:seed
4. Single tab, so you know when code reloads are complete.

General disadvantages:

1. It's not a full shell. No aliases or boolean logic || && for commands.
2. You're already in a bundled environment, so rake db:seed is going to apply to the test environment. You probably don't want that.
3. Have to ctrl-D and reload after Gemfile changes.
4. Uses some Mac OS X only features, but if you want to hack those out it shouldn't be too hard.

One advantage over even the shell is a per-project and per-environment command history.

## Contributing

To fix a problem or add a feature, use the standard pull request workflow:

    # fork it on github, then clone:
    git clone git@github.com:YOUR_USERNAME/gogo.git
    # hack away
    git push
    # then make a pull request

Once you get a pull request accepted, I'll add you so you can commit directly to the repository.

    git clone git@github.com:brianhempel/gogo.git
    # hack away
    git push

## License

Public domain; no restrictions.

And certainly: no warrantee of fitness for any purpose. It's a hack. Use at your own risk.
