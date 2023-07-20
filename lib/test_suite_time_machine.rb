require_relative "test_suite_time_machine/version"
require "timecop"

module TestSuiteTimeMachine
  DAY = 60 * 60 * 24

  def self.pretend_it_is(datetime)
    if baseline
      raise TimeTravelError, "TestSuiteTimeMachine.pretend_it_is cannot be called more than once per test run (currently set to `#{baseline}`, use `travel_temporarily_to` instead)." # rubocop:disable Layout/LineLength
    end

    datetime = "real_world" if datetime.nil? || datetime.strip.empty?

    self.baseline = Timecop.baseline = case datetime
      when "real_world"
        now
      when /\A(\d+).days.from_now\z/
        days_from_now(::Regexp.last_match(1).to_i)
      else
        parse(datetime)
      end

    Timecop.safe_mode = false
    Timecop.freeze
  end

  def self.travel_temporarily_to(*datetime, freeze: true, &block)
    raise TimeTravelError, "TestSuiteTimeMachine.travel_temporarily_to requires a block" unless block_given?

    if freeze
      Timecop.freeze(*datetime, &block)
    else
      Timecop.travel(*datetime, &block)
    end
  end

  def self.advance_time_to(datetime, **kwargs)
    if parse(datetime) < now
      raise TimeTravelError,
            "TestSuiteTimeMachine.advance_time_to cannot be called with a date in the past (#{datetime})"
    end

    travel_permanently_to(datetime, **kwargs)
  end

  def self.advance_time_by(duration, **kwargs)
    advance_time_to(now + duration, **kwargs)
  end

  def self.advance
    advance_time_by(1) # 1 second
  end

  def self.travel_permanently_to(*datetime, freeze: true)
    if freeze
      Timecop.freeze(*datetime)
    else
      Timecop.travel(*datetime)
    end
  end

  def self.reset
    unless baseline # rubocop:disable Style/IfUnlessModifier
      raise TimeTravelError, "a baseline time must be set first (#{baseline})"
    end

    Timecop.return_to_baseline
    Timecop.freeze(baseline)

    if now.to_i != baseline.to_i # rubocop:disable Style/GuardClause
      raise TimeTravelError, "Time leak! Expected '#{now}' to be at baseline '#{baseline}' after a reset"
    end
  end

  def self.revert_to_real_world_time
    Timecop.return.tap do
      Timecop.safe_mode = true
      self.baseline = nil
    end
  end

  def self.unfreeze!
    Timecop.travel(now)
  end

  def self.baseline
    Thread.current[:tstm_baseline_set]
  end

  def self.baseline=(datetime)
    Thread.current[:tstm_baseline_set] = datetime
  end

  def self.now
    if Time.respond_to?(:zone)
      Time.zone.now
    else
      Time.now
    end
  end

  def self.parse(datetime)
    return datetime unless datetime.is_a?(String)

    if Time.respond_to?(:zone)
      Time.zone.parse(datetime)
    else
      Time.parse(datetime)
    end
  end

  def self.days_from_now(days)
    if days.respond_to?(:days)
      days.days.from_now
    else
      now + (days * DAY)
    end
  end

  module RSpecHelpers
    def set_time(...)
      TestSuiteTimeMachine.travel_permanently_to(...)
    end

    def advance_time
      TestSuiteTimeMachine.advance
    end

    def advance_time_by(...)
      TestSuiteTimeMachine.advance_time_by(...)
    end

    def advance_time_to(...)
      TestSuiteTimeMachine.advance_time_to(...)
    end

    def travel_temporarily_to(...)
      TestSuiteTimeMachine.travel_temporarily_to(...)
    end

    def self.included(config)
      config.before(:each, :time) do |example|
        set_time(example.metadata[:time])
      end
    end
  end

  class TimeTravelError < StandardError; end
end
