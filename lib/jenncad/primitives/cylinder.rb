module JennCad::Primitives
  class Cylinder < Primitive
    attr_accessor :d, :h, :fn
		def initialize(args)
      super
      @d = args[:d]
      @h = args[:h]
      @fn = args[:fn]
    end
  end
end
