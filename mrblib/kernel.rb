module Kernel
  def warn(*args)
    $stderr.puts(*args)
  end
end
