module JennCad::Primitives
  class Primitive < JennCad::Thing
    def initialize(*args)
      super(*args)
    end

    def handle_margins
      @x = @opts[:x].to_d + @opts[:margins][:x].to_d
      @y = @opts[:y].to_d + @opts[:margins][:y].to_d
      @z = @opts[:z].to_d + @opts[:margins][:z].to_d
    end

    def handle_diameter
      @d = opts[:d].to_d
      @r = opts[:r].to_d
      if @d
        @r = @d/2.0
      elsif @r
        @d = @r*2
      end
    end

  end
end
