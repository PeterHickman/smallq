require 'yaml'

module Smallq
  class Config
    def self.load(filename)
      if filename.nil?
        raise 'No config file given'
      elsif File.exist?(filename)
        x = YAML.load_file(filename)
        if x.is_a?(Hash)
          return x
        else
          raise "The config file [#{filename}] is malformed YAML"
        end
      else
        raise "Unable to open the config file [#{filename}]"
      end
    end
  end
end
