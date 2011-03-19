module Moniter
  Timeslot = Struct.new(:starts_at, :ends_at) do
    def start_time
      Time.parse(starts_at)
    end

    def end_time
      Time.parse(ends_at)
    end

    def include?(time)
      time = Time.parse(time) if time.kind_of? String
      start_time <= time && time < end_time
    end

    def current?
      include?(Time.now)
    end
  end
end
