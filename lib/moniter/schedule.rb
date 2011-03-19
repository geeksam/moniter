require 'timeslot'
require 'notification'
require 'iteration'

module Moniter
  class Schedule
    attr_reader :timeslots, :notifications

    def initialize
      @timeslots = []
      @notifications = []
    end

    def iteration(options = {})
      timeslots << Timeslot.new(options[:starts_at], options[:ends_at])
    end

    def iteration_for(time)
      tb = timeslots.detect { |tb| tb.include?(time) }
      Iteration.new(tb, notifications)
    end

    def notify_when(options = {})
      options = options.invert
      notifications << Notification.new(:remain,  options[:remain])  if options[:remain]
      notifications << Notification.new(:elapsed, options[:elapsed]) if options[:elapsed]
    end

    # Gimme some sugar, baby
    # (Which is to say: this is a NOP, but maybe it makes the calling code purdier.)
    def each_iteration(&block)
      instance_eval(&block)
    end

    def current_timeslot
      timeslots.detect(&:current?)
    end
  end
end
