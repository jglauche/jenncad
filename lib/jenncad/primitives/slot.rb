module JennCad::Primitives
  class Slot < Primitive
    attr_accessor :d, :r, :h, :fn, :len_x, :len_y

    def initialize(args)
      super
      @d = args[:d]
      @a = args[:a] || 0
      @h = args[:h]
      @r = args[:r]
      @fn = args[:fn]
      @len_x = args[:x]
      @len_y = args[:y]
    end

    def to_openscad
      c1 = cylinder(d:@d,r:@r,h:@h)
      c2 = cylinder(d:@d,r:@r,h:@h)
      if @len_x
        c2.move(x:@len_x)
      end
      if @len_y
        c2.move(y:@len_y)
      end
      res = c1 & c2
      if @a > 0.0
        res = res.rotate(z:@a)
      end
      res
    end

    def end_vector
      if @a.to_f == 0.0
        return [@len_x, 0] if @len_x
        return [0, @len_y] if @len_y
      end
      if @len_x
        x = cos(PI*@a/180.0)*@len_x.to_f
        y = sin(PI*@a/180.0)*@len_x.to_f
      else
        x = -1* sin(PI*@a/180.0)*@len_y.to_f
        y = cos(PI*@a/180.0)*@len_y.to_f
      end
      [x,y]
    end

  end
end
