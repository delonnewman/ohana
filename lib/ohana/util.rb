require 'dm-core'

module Ohana
  module Util
    def hash_keys_to_sym(hash)
      h = {}
      hash.each_pair do |k, v|
        if v.is_a?(Hash)
          h[k.to_sym] = hash_keys_to_sym(v)
        else
          h[k.to_sym] = v
        end
      end
      h
    end
  end

  module Serializable
    def to_json
      h = {}
      instance_variables.each do |var|
        h[var.to_s.sub('@', '')] = instance_variable_get(var)
      end
      h.to_json
    end
  end
end

class DataMapper::Collection
  def to_json
    "[#{map { |x| x.to_json }.join(',')}]"
  end
end
