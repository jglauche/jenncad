module JennCad::Primitives
  class Cube < Primitive
    attr_accessor :x,:y,:z

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
      [@x, @y, @z]
    end

    def center_xy
      set_option :center, true
      self
    end

    def center_x
      set_option :center_x, true
      self
    end

    def center_y
      set_option :center_y, true
      self
    end

    def center_z
      set_option :center_z, true
      self
    end

#    def center
#      @transformations << Move.new({x:-@x/2,y:-@y/2,z:-@z/2})
#      self
#    end

  end
end
