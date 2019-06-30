module JennCad::Primitives
  class Cube < Primitive
    extend JennCad::Features::Cuttable

    def initialize(args)
      if args.kind_of?(Array) && args[0].kind_of?(Hash)
        args = args.first
      end
      if args.kind_of? Array
        m = {}
        if args.last.kind_of? Hash
          m = args.last
        end
        args = [:x, :y, :z].zip(args.flatten).to_h
        args.deep_merge!(m)
      end
      @opts = {
        x: 0,
        y: 0,
        z: 0,
        margins: {
          x: 0,
          y: 0,
          z: 0,
        },
        center: true,
        center_y: false,
        center_x: false,
        center_z: false,
      }.deep_merge!(args)
      handle_margins

      super(args)
      @h = @z.dup
      @calc_h = @z.dup
    end

    # used for openscad export
    def size
      [@x, @y, z+z_margin]
    end

    def not_centered
      @opts[:center] = false
    end
    alias :nc :not_centered

    def cx
      nc
      @opts[:center_x] = true
    end

    def cy
      nc
      @opts[:center_y] = true
    end

    def cz
      nc
      @opts[:center_z] = true
    end

    def centered_axis
      return [:x, :y] if @opts[:center]
      a = []
      a << :x if @opts[:center_x]
      a << :y if @opts[:center_x]
      a << :z if @opts[:center_x]
      a
    end

    def to_openscad
      self.mh(centered_axis.to_h{|a| [a, -@opts[a]] }) # center cube
    end

  end
end
