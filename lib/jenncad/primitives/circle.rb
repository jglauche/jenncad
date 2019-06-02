module JennCad::Primitives
  class Circle < Primitive
    attr_accessor :d, :r, :fn
    def initialize(args)
      super
      @d = args[:d]
      @r = args[:r]
      @fn = args[:fn]
    end
  end
end
