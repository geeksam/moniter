module Moniter
  Iteration = Struct.new(:timeslot, :notifications) do
    extend Forwardable
    def_delegators :timeslot, :start_time, :end_time

    def alarm_times
      notifications.map { |n|
        anchor = (n.offset < 0) ? end_time : start_time
        anchor + n.offset
      }
    end
  end
end
