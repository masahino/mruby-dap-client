module DAP
  module Type
    # descriptor for source code
    class Source < Base
      attr_reader :path, :name

      def initialize(path)
        super
        @path = File.expand_path path
        @name = File.basename @path
      end
    end
  end
end
