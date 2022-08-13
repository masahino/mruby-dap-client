module DAP
  module Type
    # properties of breakpoint
    class FunctionBreakpoint < Base
      def initialize(name)
        super
        @name = name
      end
    end
  end
end
