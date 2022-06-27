module JennCad::Features
  class OpenScadImport < Aggregation
    attr_accessor :import, :args

    def initialize(import, name=nil, args={})
      @import = import
      @name = name || @import
      @args = args
      super(@name)
    end
  end
end
