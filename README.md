# Test Suite Time Machine (TSTM)

This library operates on the principle that time is a variable like any other,
and should be controlled for in a test suite.  It builds on top of Timecop to
provide an intuitive interface to set and manipulate time at different levels
of your test suite, whether to set a specific time for a single test, or to
pretend to run the entire suite on New Year's Day 2038.

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add test_suite_time_machine

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install test_suite_time_machine

## Usage

### Full suite

Use `TestSuiteTimeMachine.pretend_it_is(datetime)` to set and freeze the time for the entire test suite.
Usually this is done in your `rails_helper` or `spec_helper` file
immediately after your gems are loaded.

This is also your opportunity to pass in a specific date and time
if you want to run your suite on that specific date.

```ruby
TestSuiteTimeMachine.pretend_it_is(ENV.fetch('TEST_DATE_AND_TIME', 'real_world'))
```

The options are:
- `'real_world'` - the default, uses the real date and time
- `'n.days.from_now'` - e.g. `'1.day.from_now'`
- Any Ruby-parseable timestamp, usually ISO8601

TSTM will always return to this baseline after each test.

### Group-level

To set the date/time for a given group of tests, such as a `describe` block, or `context` block, use `TestSuiteTimeMachine.travel_permanently_to(...)` before the tests in question.  This will move and freeze time as specified, and return to the baseline after the test has finished.

### Test-level

Once you're in the test itself, use the following methods to manipulate time as needed:

- `TestSuiteTimeMachine.advance` - move time forward by 1 second
- `TestSuiteTimeMachine.advance_time_by(seconds)` - move time forward by the specified number of seconds
- `TestSuiteTimeMachine.advance_time_to(datetime)` - move time forward to the specified datetime

You cannot use these methods to move time backwards; if you arbitrarily step backwards and forwards in a test, it confuses people.

If you need to move backwards in time e.g. to set up some records
created in the past, either use `travel_permanently_to` to set the
time for the entire test group, or use `travel_temporarily_to` to set the time for the duration of the given block.

### RSpec

If you're using RSpec, TSTM provides a set of helpers for clarity
and convenience, as well as reducing coupling between your tests
and this library.

```ruby
RSpec.configure do |config|
  config.include TestSuiteTimeMachine::RSpecHelpers
end
```

This provides the following functionality:
- adds `set_time(...)` as an alias for `TestSuiteTimeMachine.travel_permanently_to(...)`
- adds `advance_time` as an alias for `TestSuiteTimeMachine.advance`
- adds `advance_time_by(seconds)` as an alias for `TestSuiteTimeMachine.advance_time_by(seconds)`
- adds `advance_time_to(datetime)` as an alias for `TestSuiteTimeMachine.advance_time_to(datetime)`
- adds `travel_temporarily_to(datetime)` as an alias for `TestSuiteTimeMachine.travel_temporarily_to(datetime)`

It also adds the RSpec tag `time` which is a succinct way of invoking
`travel_permanently_to` for a given test.

```ruby
RSpec.describe "Santa's schedule" do
  context "when it Christmas Eve", time: '2023-12-24 10:00' do
    it "is extremely busy" do
      # ...
    end
  end
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/SmartCasual/test_suite_time_machine

## Licence

The gem is available as open source under the terms of the [MIT Licence](https://opensource.org/licenses/MIT).
