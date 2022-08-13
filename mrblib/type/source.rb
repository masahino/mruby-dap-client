module DAP
  module Type
    # descriptor for source code
    class Source < Base
      def initialize(path)
        super
        @path = File.expand_path path
        @name = File.basename @path
      end
    end
  end
end
