module JennCad::Primitives
  class Slot < Primitive
    attr_accessor :d, :r, :h, :fn, :len_x, :len_y

    def initialize(args)
      if args.kind_of?(Array) && args[0].kind_of?(Hash)
        args = args.first
      end
      if args.kind_of? Array
        m = {}
        if args.last.kind_of? Hash
          m = args.last
        end
        args = [:d, :z].zip(args.flatten).to_h
        args.deep_merge!(m)
      end

      args[:z] ||= args[:h]

      @opts = {
        d: 0,
        a: 0,
        z: nil,
        r: nil,
        x: 0,
        y: 0,
        margins: {
          r: 0,
          d: 0,
          z: 0,
        },
      }.deep_merge!(args)

      super(opts)

      @d = @opts[:d]
      @a = @opts[:a]
      @h = @opts[:h]
      @r = @opts[:r] || nil
      if @r
        @d = @r * 2
      end
      @fn = @opts[:fn]
      @len_x = @opts[:x]
      @len_y = @opts[:y]
      tx = @opts[:tx] || @opts[:total_x] || nil
      ty = @opts[:ty] || @opts[:total_y] || nil
      if tx
        @len_x = tx - @d
      end
      if ty
        @len_y = ty - @d
      end

      # TODO: this needs anchors like cube
      # TODO: color on this needs to apply to hull, not on the cylinders.

    end

    def to_openscad
      c1 = cylinder(@opts)
      c2 = cylinder(@opts)
      if @len_x
        c2.move(x:@len_x)
      end
      if @len_y
        c2.move(y:@len_y)
      end
      res = c1 & c2
      if @a != 0.0
        res = res.rotate(z:@a)
      end
      if @transformations && @transformations.size > 0
        res = UnionObject.new([res])
        res.transformations = @transformations
        return res
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
