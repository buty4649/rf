module Kernel
  def warn(*)
    $stderr.puts(*)
  end
end
