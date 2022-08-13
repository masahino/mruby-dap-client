module DAP
  module Type
    # properties of breakpoint
    class Breakpoint < Base
      def initialize(line)
        super
        @line = line
      end
    end
  end
end
