module Moniter
  Notification = Struct.new(:time_string, :alert_methods) do
    class << self
      def build(iteration, milestone)
        time_string = iteration.alarm_time(milestone).to_moniter_s
        new(time_string, milestone.alert_methods)
      end
    end

    def time
      Time.parse(time_string)
    end

    def future?
      time > Time.now
    end
  end
end
