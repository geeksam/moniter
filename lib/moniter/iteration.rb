module Moniter
  Iteration = Struct.new(:schedule, :timeslot) do
    extend Forwardable
    def_delegators :timeslot, :start_time, :end_time, :include?
    def_delegators :schedule, :milestones, :alert_callbacks
    attr_reader :notifications

    def initialize(*args)
      super
      @notifications = milestones.map { |ms| Notification.new(self, ms) }
    end

    def alarm_time(milestone)
      anchor = self.send("#{milestone.anchor}_time")
      anchor + milestone.offset
    end

    def notify!
      n = notifications.shift until notifications.empty? || notifications.first.future?
      return if n.nil?
      n.perform
    end

    def minutes_elapsed
      ((Time.now - start_time) / 1.minute).floor.to_i
    end

    def minutes_remaining
      ((end_time - Time.now) / 1.minute).floor.to_i
    end

    def to_s
      "(Iteration: %s-%s)" % [start_time, end_time].map(&:to_moniter_s)
    end
  end
end
