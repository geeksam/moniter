require 'timeslot'
require 'milestone'
require 'iteration'
require 'notification'

module Moniter
  class Schedule
    attr_reader :timeslots, :milestones, :alert_callbacks

    def initialize
      @timeslots = []
      @milestones = []
      @alert_callbacks = {}
    end

    ##### These methods comprise the public API to be used in client scripts #####

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
      ts = timeslot_for(time)
      return if ts.nil?
      Iteration.new(self, ts)
    end

    def timeslot_for(time)
      timeslots.detect { |ts| ts.include?(time) }
    end

    def current_timeslot
      timeslot_for(Time.now)
    end

    def current_iteration
      return @current_iteration if @current_iteration && @current_iteration.include?(Time.now)
      @current_iteration = iteration_for(Time.now)
    end

    def load_current_or_next_iteration(resolution = 15.minutes)
      return @current_or_next_iteration unless @current_or_next_iteration.nil?
      t = Time.now
      while @current_or_next_iteration.nil?
        @current_or_next_iteration = iteration_for(t)
        puts "Iteration for #{t.to_moniter_s}? #{@current_or_next_iteration ? 'yup!' : 'nope.'}"
        t += resolution
      end
      puts "done!"
    end

    def tick
      load_current_or_next_iteration
      @current_or_next_iteration && @current_or_next_iteration.notify!
      @current_or_next_iteration = nil if @current_or_next_iteration != current_iteration
      nil
    end
  end
end
