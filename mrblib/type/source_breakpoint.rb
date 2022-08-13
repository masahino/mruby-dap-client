module DAP
  module Type
    # properties of breakpoint
    class SourceBreakpoint < Base
      def initialize(line, column = 1)
        super
        @line = line
        @column = column
      end
    end
  end
end
