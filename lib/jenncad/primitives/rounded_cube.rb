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
        flat_edges: nil,
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
      handle_margins
      handle_diameter
      super(opts)
    end

    def to_openscad
      return cube(@opts) if @d == 0
      # make diameter not bigger than any side
      @d = [@d, @x, @y].min
      res = HullObject.new(
        cylinder(d:@d, h:z+z_margin),
        cylinder(d:@d).move(x: @x - @d, y: 0),
        cylinder(d:@d).move(x: 0, y: @y - @d),
        cylinder(d:@d).move(x: @x - @d, y: @y - @d),
      ).moveh(xy: @d)

      res += flat_edge(@opts[:flat_edges])

      res.transformations = @transformations
      res.moveh(centered_axis.to_h{|a| [a, -@opts[a]] })
    end

    def flat_edge(edge)
      case edge
      when Array
        #ruby2.7 test- edge.map(&self.:flat_edge)
        edge.map{|x| flat_edge(x) }
      when :up
        cube(@x, @y/2.0, @z).moveh(y:@y/2.0)
      when :down
        cube(@x, @y/2.0, @z).moveh(y:-@y/2.0)
      when :right
        cube(@x/2.0, @y, @z).moveh(x:@x/2.0)
      when :left
        cube(@x/2.0, @y, @z).moveh(x:-@x/2.0)
      else
        nil
      end
    end

  end
end
