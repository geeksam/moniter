module Moniter
  Notification = Struct.new(:time_string, :milestone) do
    class << self
      def build(iteration, milestone)
        time_string = iteration.alarm_time(milestone).to_moniter_s
        new(time_string, milestone)
      end
    end

    def time
      Time.parse(time_string)
    end

    def future?
      time > Time.now
    end

    def perform(iteration)
      message = case
      when milestone.anchor == :start && milestone.offset.zero? then 'Iteration started'
      when milestone.anchor == :end then "#{iteration.minutes_remaining} minutes remaining"
      else "#{iteration.minutes_elapsed} minutes elapsed"
      end

      milestone.alert_methods.each do |alert_method|
        callback = iteration.alert_callbacks[alert_method]
        callback && callback.call(message)
      end
    end
  end
end
