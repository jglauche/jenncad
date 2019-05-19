module JennCad::Primitives
  class Sphere < Primitive
    attr_accessor :d, :r, :fn
    def initialize(args)
      super
      @d = args[:d]
      @r = args[:r]
      @fn = args[:fn]
    end
  end
end
