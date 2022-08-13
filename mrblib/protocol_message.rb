module DAP
  # protocol message
  class ProtocolMessage
    def to_h
      instance_variables.map do |k|
        v = instance_variable_get(k)
        if v.is_a? Type
          [k.to_s[1..-1], v.to_h]
        else
          [k.to_s[1..-1], v]
        end
      end.to_h.delete_if { |_k, v| v.nil? }
    end

    def to_json(*_args)
      to_h.to_json
    end

    def to_s
      to_h
    end
  end
end
