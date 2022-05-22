module JennCad::Primitives
  class Slot < Primitive
    include CircleIsh
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
      args = parse_xyz_shortcuts(args)
      if args[:z].to_d > 0
        args[:h] = args[:z]
      else
        args[:z] = nil
      end

      @opts = {
        d: 0,
        a: 0,
        r: nil,
        x: 0,
        y: 0,
        z: nil,
        d1: nil,
        d2: nil,
        mode: :auto,
        cz: false,
        az: false,
        margins: {
          r: 0,
          d: 0,
          z: 0,
        },
      }.deep_merge!(args)

      super(opts)

      @d = @opts[:d].to_d
      @a = @opts[:a].to_d
      @h = @opts[:h].to_d
      @z = @h
      @x = @opts[:x].to_d
      @y = @opts[:y].to_d

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

      set_anchors
    end

    def cz
      @opts[:cz] = true
      @transformations << Move.new(z: -@z / 2.0)
      set_anchors
      self
    end


    def set_anchors
      @anchors = {} # reset anchors
      rad = radius

      if @x > 0
        set_anchor :left, x: - rad
        set_anchor :right, x: @x + rad
      elsif @x < 0
        set_anchor :left, x: @x - rad
        set_anchor :right, x: rad
      else
        set_anchor :left, x: -rad
        set_anchor :right, x: rad
      end
      if @y > 0
        set_anchor :bottom, y: - rad
        set_anchor :top, y: @y + rad
      elsif @y < 0
        set_anchor :bottom, y: @y - rad
        set_anchor :top, y: rad
      else
        set_anchor :bottom, y: -rad
        set_anchor :top, y: rad
      end

      set_anchor :center1, xy: 0
      set_anchor :center2, x: @x, y: @y

      # TODO: figure out if we also want to have "corners"
      # - possibly move it like a cube
      # - points at 45 ° angles might not be that useful unless you can get the point on the circle at a given angle
      # - inner/outer points could be useful for small $fn values

      if @opts[:cz]
        set_anchor :bottom_face, z: -@z/2.0
        set_anchor :top_face, z: @z/2.0
      else
        set_anchor :bottom_face, z: 0
        set_anchor :top_face, z: @z
      end
    end

    def get_mode
      if @opts[:d1] && @opts[:d2]
        case @opts[:mode]
        when nil, :auto
          :dia1
        when :cyl
          :cyl
        else
          :dia1
        end
      else
        :default
      end
    end

    def to_openscad
      mode = get_mode

      opts = @opts.clone
      opts.delete(:color)

      case mode
      when :default
        c1 = ci(opts)
        c2 = ci(opts)
      when :dia1 # new default mode; d1 start dia, d2 end dia
        c1 = ci(opts.merge(d: @opts[:d1]))
        c2 = ci(opts.merge(d: @opts[:d2]))
      when :cyl # old mode; use cylinders
        c1 = cy(opts)
        c2 = cy(opts)
      end

      if @len_x
        c2.move(x:@len_x)
      end
      if @len_y
        c2.move(y:@len_y)
      end
      res = c1 & c2
      if mode != :cyl && @z.to_d > 0
        res = res.e(@z)
      elsif @opts[:az] == true
        # TODO: this needs testing, may not work
        res = res.auto_extrude
      end
      res.inherit_color(self)

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
      if @a.to_d == 0.0
        return [@len_x, 0] if @len_x
        return [0, @len_y] if @len_y
      end
      if @len_x
        x = cos(PI*@a/180.0)*@len_x.to_d
        y = sin(PI*@a/180.0)*@len_x.to_d
      else
        x = -1* sin(PI*@a/180.0)*@len_y.to_d
        y = cos(PI*@a/180.0)*@len_y.to_d
      end
      [x,y]
    end

  end
end
