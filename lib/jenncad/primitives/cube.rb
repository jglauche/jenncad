module JennCad::Primitives
  class Cube < Primitive
    extend JennCad::Features::Cuttable


    def feed_opts(args)
      # FIXME: this doesn't seem to work
      if args.kind_of? Array
        m = {}
        if args.last.kind_of? Hash
          m = args.last
        end
        args = [:x, :y, :z].zip(args.flatten).to_h
        args.deep_merge!(m)
        @opts.deep_merge!(args)
      else
        @opts.deep_merge!(args)
      end
    end

    def initialize(args)
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
      }
      if args.kind_of? Array
        args.each do |a|
          feed_opts(parse_xyz_shortcuts(a))
        end
      else
        feed_opts(parse_xyz_shortcuts(args))
      end


      handle_margins
      super(z: @opts[:z])
      @h = @z.dup
      @calc_h = @z.dup
    end

    # used for openscad export
    def size
      [@x, @y, z+z_margin]
    end

    def not_centered
      @opts[:center] = false
      self
    end
    alias :nc :not_centered

    def cx
      nc
      @opts[:center_x] = true
      self
    end

    def cy
      nc
      @opts[:center_y] = true
      self
    end

    def cz
      nc
      @opts[:center_z] = true
      self
    end

    def centered_axis
      return [:x, :y] if @opts[:center]
      a = []
      a << :x if @opts[:center_x]
      a << :y if @opts[:center_y]
      a << :z if @opts[:center_z]
      a
    end

    def to_openscad
      self.mh(centered_axis.to_h{|a| [a, -@opts[a]] }) # center cube
    end

  end
end
