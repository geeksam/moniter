class Fixnum
  def minutes
    self * 60
  end

  def hours
    minutes * 60
  end

  def days
    hours * 24
  end

  alias :minute :minutes
  alias :hour :hours
  alias :day :days
end

class Time
  def to_moniter_s
    strftime('%I:%M %p')
  end
end
