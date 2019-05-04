module JennCad::Primitives
  class Cylinder < Primitive
    attr_accessor :d, :h
		def initialize(args)
      @d = args[:d]
      @h = args[:h]
    end
  end
end
