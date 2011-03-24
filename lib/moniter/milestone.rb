module Moniter
  Milestone = Struct.new(:anchor, :interval, :alert_methods) do
    class << self
      def build_for_anchor(anchor, options = {})
        alert_methods = [options[:via]]
        new(anchor, 0, alert_methods)
      end

      def build_from_options(options = {})
        anchor, interval, alert_methods = nil, nil, []
        options.each do |key, val|
          case
          when key == :via      then alert_methods << val
          when val == :elapsed  then anchor, interval = :start, key
          when val == :remain   then anchor, interval = :end, key
          end
        end
        new(anchor, interval, alert_methods)
      end
    end

    def initialize(anchor, interval, alert_methods = [])
      super(anchor, interval, [alert_methods].flatten)
    end

    def offset
      multiplier = (:end == anchor ? -1 : 1)
      interval * multiplier
    end

    def message(iteration)
      return 'Iteration started'  if boundary? && start?
      return 'Iteration complete' if boundary? && end?
      return "#{iteration.minutes_elapsed} minutes elapsed"     if start?
      return "#{iteration.minutes_remaining} minutes remaining" if end?
    end

    def start?
      :start == anchor
    end

    def end?
      :end == anchor
    end

    def boundary?
      offset.zero?
    end
  end
end
