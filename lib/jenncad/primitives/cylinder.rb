module JennCad::Primitives
  class Cylinder < Primitive
    def initialize(args)
      @d = args[:d]
      @h = args[:h]
    end
  end
end
