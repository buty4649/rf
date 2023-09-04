class String
  def red
    "\e[31m#{self}\e[0m"
  end

  def try_to_i
    Integer(self)
  rescue ArgumentError
    nil
  end

  def try_to_f
    Float(self)
  rescue ArgumentError
    nil
  end
end
