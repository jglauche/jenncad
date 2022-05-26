module JennCad
  class Transformation
    attr_accessor :x,:y,:z, :coordinates
    def initialize(args)
      @pos = args[:pos]
      @x = args[:x]
      @y = args[:y]
      @z = args[:z]
    end

    def coordinates
      @pos.to_a
    end
  end
end
