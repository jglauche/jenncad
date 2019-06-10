module JennCad::Primitives
  class Primitive < JennCad::Thing
    def initialize(*args)
      super(*args)
    end

    def handle_margins
      @x = @opts[:x] + @opts[:margins][:x]
      @y = @opts[:y] + @opts[:margins][:y]
      @z = @opts[:z] + @opts[:margins][:z]
    end

    def handle_diameter
      @d = opts[:d]
      @r = opts[:r]
      if @d
        @r = @d/2.0
      elsif @r
        @d = @r*2
      end
    end

  end
end
