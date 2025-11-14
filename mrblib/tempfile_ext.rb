class Tempfile
  def close(real: false)
    super()
    delete if real

    nil
  end
end
