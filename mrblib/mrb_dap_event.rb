module DAP
  # event
  class Client
    def initialized
      @initialized = true
      @source_breakpoints.each do |path, lines|
        send_breakpoints(path, lines)
      end
    end
  end
end
