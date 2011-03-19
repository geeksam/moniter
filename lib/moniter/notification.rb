module Moniter
  Notification = Struct.new(:anchor, :interval) do
    def offset
      multiplier = (:remain == anchor ? -1 : 1)
      interval * multiplier
    end
  end
end
