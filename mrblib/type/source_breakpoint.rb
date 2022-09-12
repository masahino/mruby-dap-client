module DAP
  module Type
    # properties of breakpoint
    class SourceBreakpoint < Base
      attr_reader :line, :column

      def initialize(line, column = 1)
        @line = line
        @column = column
      end
    end
  end
end
