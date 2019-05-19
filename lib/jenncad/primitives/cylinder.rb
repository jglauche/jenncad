module JennCad::Primitives
  class Cylinder < Primitive
    attr_accessor :d, :r, :h, :fn
		def initialize(args)
      super
      @d = args[:d]
      @h = args[:h]
      @r = args[:r]
      @fn = args[:fn]
    end
  end
end
