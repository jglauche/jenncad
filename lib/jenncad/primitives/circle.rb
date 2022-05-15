module JennCad::Primitives
  class Circle < Primitive
    attr_accessor :d, :r, :fn
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


      @opts = {
        d: 0,
        d1: nil,
        d2: nil,
        r1: nil,
        r2: nil,
        z: nil,
        r: 0,
        cz: false,
        margins: {
          r: 0,
          d: 0,
          z: 0,
        },
        fn: nil,
      }.deep_merge!(args)
      init(args)
      @dimensions = [:x, :y]
      handle_radius_diameter
      handle_fn
      set_anchors_2d
    end

    def set_anchors_2d
      @anchors = {} # reset anchors
      if @opts[:d]
        rad = @opts[:d] / 2.0
      else
        rad = @opts[:r]
      end

      # Similar to cube
      set_anchor :left, x: -rad
      set_anchor :right, x: rad
      set_anchor :top, y: rad
      set_anchor :bottom, y: -rad
    end

    def openscad_params
      res = {}
      [:d, :fn].each do |n|
        res[n] = self.send n
      end
      res
    end

    def handle_fn
      case @opts[:fn]
        when nil, 0
          $fn = auto_dn!
        else
          @fn = @opts[:fn]
      end
    end

    def auto_dn!
      case @d
        when (16..)
          @fn = (@d*4).ceil
        else
          @fn = 64
      end
    end

    def handle_radius_diameter
      case @opts[:d]
      when 0, nil
        @r = @opts[:r].to_d + @opts[:margins][:r].to_d
        @d = @r * 2.0
      else
        @d = @opts[:d].to_d + @opts[:margins][:d].to_d
        @r = @d / 2.0
      end

      case @opts[:d1]
      when 0, nil
      else
        @d1 = @opts[:d1].to_d + @opts[:margins][:d].to_d
        @d2 = @opts[:d2].to_d + @opts[:margins][:d].to_d
      end

      case @opts[:r1]
      when 0, nil
      else
        @d1 = 2 * @opts[:r1].to_d + @opts[:margins][:d].to_d
        @d2 = 2 * @opts[:r2].to_d + @opts[:margins][:d].to_d
      end
    end


  end
end
