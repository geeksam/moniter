require 'timeslot'
require 'milestone'
require 'iteration'
require 'notification'

module Moniter
  class Schedule
    attr_reader :timeslots, :milestones

    def initialize
      @timeslots = []
      @milestones = []
    end

    def iteration(options = {})
      timeslots << Timeslot.new(options[:starts_at], options[:ends_at])
    end

    def iteration_for(time)
      tb = timeslots.detect { |tb| tb.include?(time) }
      Iteration.new(tb, milestones)
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

    def current_timeslot
      timeslots.detect(&:current?)
    end
  end
end
