module JennCad::Primitives
  class OpenScadImport < Aggregation
    attr_accessor :import, :args

    def initialize(import, name, args)
      @import = import
      @name = name
      @args = args
    end
  end
end
