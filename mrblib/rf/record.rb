module Rf
  class Record < Enumerator
    def self.read(reader)
      new do |y|
        while record = reader.gets
          y << record
        end
      end
    end
  end
end
