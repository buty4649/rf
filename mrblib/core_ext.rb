class String
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
