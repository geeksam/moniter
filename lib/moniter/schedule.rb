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

    def notify_at(anchor, options = {})
      notifications << Notification.build_for_anchor(anchor, options)
    end

    def notify_when(options = {})
      notifications << Notification.build_from_options(options)
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
