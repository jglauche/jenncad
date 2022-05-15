module JennCad::Primitives
  class Cube < Square
    extend JennCad::Features::Cuttable

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
      init


      handle_margins
      @h = @z.dup
      @calc_h = @z.dup

      @dimensions = [:x, :y, :z]

      set_anchors
    end

    def set_anchors
      set_anchors_2d
      if @opts[:center_z]
        set_anchor :bottom_face, z: -@z/2.0
        set_anchor :top_face, z: @z/2.0
      else
        set_anchor :bottom_face, z: 0
        set_anchor :top_face, z: @z
      end


    end

    # used for openscad export
    def size
      [@x, @y, z+z_margin]
    end

    def cz
      nc
      @opts[:center_z] = true
      set_anchors
      self
    end
    alias :center_z :cz

  end
end
