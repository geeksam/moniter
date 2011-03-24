class Fixnum
  def seconds
    self
  end

  def minutes
    self * 60
  end

  def hours
    minutes * 60
  end

  def days
    hours * 24
  end

  alias :second :seconds
  alias :minute :minutes
  alias :hour :hours
  alias :day :days
end

class Time
  def to_moniter_s
    strftime('%I:%M %p')
  end
end
