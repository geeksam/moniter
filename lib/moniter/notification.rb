module Moniter
  Notification = Struct.new(:iteration, :milestone) do
    def time
      iteration.alarm_time(milestone)
    end

    def future?
      time > Time.now
    end

    def perform
      message = milestone.message(iteration)
      milestone.alert_methods.each do |alert_method|
        callback = iteration.alert_callbacks[alert_method]
        callback && callback.call(message)
      end
    end
  end
end
