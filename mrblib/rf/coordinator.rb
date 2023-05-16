module Rf
  module Coordinator
    def self.load(config, io)
      type = config.type
      case type
      when 'text'
        Coordinator::Text
      when 'json'
        Coordinator::Json
      when 'yaml'
        Coordinator::Yaml
      else
        $stderr.puts "Unknown parser: #{type}"
        exit 1
      end.new(config, io)
    end
  end
end
