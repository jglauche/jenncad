module JennCad::Primitives
  class Polygon < Primitive
    attr_accessor :points
    def initialize(args)
      super
      @points = args[:points]
    end
  end
end
