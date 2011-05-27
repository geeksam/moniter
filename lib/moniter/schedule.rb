require 'timeslot'
require 'milestone'
require 'iteration'
require 'notification'

module Moniter
  class Schedule
    attr_reader :timeslots, :milestones, :alert_callbacks, :sleep_interval

    def initialize
      @timeslots = []
      @milestones = []
      @alert_callbacks = {}
      @sleep_interval = 30.seconds
    end

    ##### These methods comprise the public API to be used in client scripts #####

    def clock_resolution(time_in_seconds)
      @sleep_interval = time_in_seconds
    end

    def workdays
      @workdays ||= (1..7).to_a
    end

    def workdays_are(*args)
      @workdays = []
      args.each do |arg|
        case arg
        when Integer
          workdays << arg
        when Range
          arg.each { |wday| workdays << wday }
        end
      end
    end

    def iteration(options = {})
      timeslots << Timeslot.new(options[:starts_at], options[:ends_at])
    end

    def to_notify_via(name, &block)
      alert_callbacks[name] = lambda &block
    end

    def notify_at(anchor, options = {})
      milestones << Milestone.build_for_anchor(anchor, options)
    end

    def notify_when(options = {})
      milestones << Milestone.build_from_options(options)
    end

    # Gimme some sugar, baby
    # (Which is to say: this is a NOP, but maybe it makes the calling code purdier.)
    def each_iteration(&block)
      instance_eval(&block)
    end

    ##### End of scripting API; these are only public to make testing a little easier #####

    def iteration_for(time)
      time = Time.parse(time) unless time.kind_of?(Time)
      return unless workdays.include?(time.wday)
      ts = timeslots.detect { |ts| ts.include?(time) }
      return if ts.nil?
      Iteration.new(self, ts)
    end

    def current_iteration
      return @current_iteration if @current_iteration && @current_iteration.include?(Time.now)
      @current_iteration = iteration_for(Time.now)
    end

    def tick
      if @prev_iteration && (@prev_iteration != current_iteration)
        # We've missed the end of an iteration; give it a chance to notify the user that it's over
        @prev_iteration.notify!
      end
      @prev_iteration ||= current_iteration
      current_iteration && current_iteration.notify!
      nil
    end

    %w[sun mon tue wed thu fri sat].each_with_index do |weekday, i|
      define_method(weekday) { i }
    end
  end
end
