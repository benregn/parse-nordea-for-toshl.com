module Helpers
  def self.change_key_name(hash, switch_keys)
    switch_keys.each do |old_key, new_key|
      hash[new_key] = hash[old_key]
      hash.delete old_key
    end
    return hash
  end
end
