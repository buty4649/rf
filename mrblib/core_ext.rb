class String
  def red
    "\e[31m#{self}\e[0m"
  end

  def magenta
    "\e[35m#{self}\e[0m"
  end

  def cyan
    "\e[36m#{self}\e[0m"
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

class Tempfile
  def close(real: false)
    super()
    delete if real

    nil
  end
end
