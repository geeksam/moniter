module Moniter
  Iteration = Struct.new(:timeslot, :milestones) do
    extend Forwardable
    def_delegators :timeslot, :start_time, :end_time
    attr_reader :notifications

    def initialize(*args)
      super
      @notifications = milestones.map { |ms| Notification.build(self, ms) }
    end

    def alarm_time(milestone)
      anchor = self.send("#{milestone.anchor}_time")
      anchor + milestone.offset
    end

    def notify!
      n = notifications.shift until notifications.empty? || notifications.first.future?
      n && n.alert
    end
  end
end
