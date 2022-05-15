module JennCad::Primitives
  class RoundedCube < Cube
    attr_accessor :d, :r
    include JennCad::Features::Cuttable

    def initialize(args)

      if args.kind_of?(Array) && args[0].kind_of?(Hash)
        args = args.first
      end
      if args.kind_of? Array
        m = {}
        if args.last.kind_of? Hash
          m = args.last
        end
        args = [:x, :y, :z, :d].zip(args.flatten).to_h.compact
        args.deep_merge!(m)
      end

      @opts = {
        d: 5,
        x: 0,
        y: 0,
        z: nil,
        r: nil,
        flat_edges: [],
        center: true,
        center_y: false,
        center_x: false,
        center_z: false,
        margins: {
          r: 0,
          d: 0,
          x: 0,
          y: 0,
          z: 0,
        },
      }.deep_merge!(args)
      if args.kind_of? Array
        args.each do |a|
          feed_opts(parse_xyz_shortcuts(a))
        end
      else
        feed_opts(parse_xyz_shortcuts(args))
      end
      init(args)


      handle_margins
      handle_diameter
      if @opts[:z] && opts[:z].to_d > 0
        @dimensions = [:x, :y, :z]
      else
        @dimensions = [:x, :y]
      end

    end

    def to_openscad
      # FIXME: this check needs to be done on object creation
      #        otherwise it fails to position it
      if @d == 0
        if @z.to_d > 0
          return cube(@opts)
        else
          return square(@opts)
        end
      end
      # make diameter not bigger than any side
      d = [@d, @x, @y].min
      res = HullObject.new(
        circle(d: d),
        circle(d: d).move(x: @x - d, y: 0),
        circle(d: d).move(x: 0, y: @y - d),
        circle(d: d).move(x: @x - d, y: @y - d),
      )
      res = res.move(xy: d/2.0)

      @opts[:flat_edges].each do |edge|
        res += apply_flat_edge(edge)
      end

      if @z.to_d > 0
        res = res.extrude(z: @z + z_margin)
      end

      res = union(res) # put everything we have in a parent union that we can apply the transformations of this object of
      res.transformations = @transformations

      res.moveh(centered_axis.to_h{|a| [a, -@opts[a]] })
      res.inherit_color(self)
      res
    end

    def flat(*edges)
      @opts[:flat_edges] ||= []
      edges.each do |edge|
        @opts[:flat_edges] << edge
      end
      self
    end

    private
    def apply_flat_edge(edge)
      case edge
      when :up, :top
        square(x: @x, y: @y/2.0).nc.moveh(y:@y)
      when :down, :bottom
        square(x: @x, y: @y/2.0).nc
      when :right
        square(x: @x/2.0, y: @y).nc.moveh(x:@x)
      when :left
        square(x: @x/2.0, y: @y).nc
      else
        nil
      end
    end

  end
end
