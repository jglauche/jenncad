module JennCad::Primitives
  class Cylinder < Primitive
    attr_accessor :d, :r, :fn
    def initialize(args)
      @d = args[:d]
      @z = args[:z] || args[:h]
      @r = args[:r]
      @fn = args[:fn]
      args[:z] ||= @z
      super(args)
    end

    def h
      z
    end

  end
end
