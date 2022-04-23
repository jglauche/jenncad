module JennCad::Primitives
  class Cylinder < Primitive
    attr_accessor :d, :d1, :d2, :r, :fn
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
        d1: nil,
        d2: nil,
        r1: nil,
        r2: nil,
        z: nil,
        r: 0,
        margins: {
          r: 0,
          d: 0,
          z: 0,
        },
        fn: nil,
      }.deep_merge!(args)

      # FIXME:
      # - margins calculation needs to go to output
      # - assinging these variables has to stop
      # - r+z margin not implemented atm
      # - need to migrate classes to provide all possible outputs (and non-conflicting ones) to openscad exporter
      @z = args[:z] || args[:h]
      handle_radius_diameter
      handle_fn
      super(args)
    end

    def openscad_params
      res = {}
      if @opts[:d1]
        [:d1, :d2, :h, :fn].each do |n|
          res[n] = self.send n
        end
      else
        [:d, :h, :fn].each do |n|
          res[n] = self.send n
        end
      end
      res
    end

    # Centers the cylinder around it's center point by height
    # This will transform the cylinder around the center point.
    def cz
      @transformations << Move.new(z: -@z / 2.0)
      self
    end

    def handle_fn
      case @opts[:fn]
        when nil, 0
          $fn = auto_fn!
        else
          @fn = @opts[:fn]
      end
    end

    def auto_fn!
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
        @r = @opts[:r].to_f + @opts[:margins][:r].to_f
        @d = @r * 2.0
      else
        @d = @opts[:d].to_f + @opts[:margins][:d].to_f
        @r = @d / 2.0
      end

      case @opts[:d1]
      when 0, nil
      else
        @d1 = @opts[:d1].to_f + @opts[:margins][:d].to_f
        @d2 = @opts[:d2].to_f + @opts[:margins][:d].to_f
      end

      case @opts[:r1]
      when 0, nil
      else
        @d1 = 2 * @opts[:r1].to_f + @opts[:margins][:d].to_f
        @d2 = 2 * @opts[:r2].to_f + @opts[:margins][:d].to_f
      end
    end

    def h
      z + z_margin
    end

  end
end
