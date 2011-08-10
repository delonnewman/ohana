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
end
