class Fixnum
  def seconds
    self * 60
  end

  def minutes
    seconds * 60
  end
end