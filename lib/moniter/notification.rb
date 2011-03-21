module Moniter
  Notification = Struct.new(:time, :alert_methods) do
    class << self
      def build(iteration, milestone)
        time = iteration.alarm_time(milestone)
        new(time, milestone.alert_methods)
      end
    end
  end
end
