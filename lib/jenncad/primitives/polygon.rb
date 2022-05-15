module JennCad::Primitives
  class Polygon < Primitive
    attr_accessor :points, :paths
    def initialize(args)
      @points = args[:points]
      @paths = args[:paths]
      @convexity = args[:convexity] || 10
      @dimensions = [:x, :y]
      super
    end
  end
end
