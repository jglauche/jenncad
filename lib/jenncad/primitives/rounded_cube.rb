module JennCad::Primitives
  class RoundedCube < Primitive
    attr_accessor :d, :r

    def initialize(args)
      if args.kind_of?(Array) && args[0].kind_of?(Hash)
        args = args.first
      end
      if args.kind_of? Array
        m = {}
        if args.last.kind_of? Hash
          m = args.last
        end
        args = [:x, :y, :z, :d].zip(args.flatten).to_h
        args.deep_merge!(m)
      end

      @opts = {
        d: 5,
        x: 0,
        y: 0,
        z: nil,
        r: nil,
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
      res = HullObject.new(
        cylinder(d:@d, h:@z).move(x: -@x/2.0 + @d/2.0, y: @y/2.0 - @d/2.0),
        cylinder(d:@d).move(x: @x/2.0 - @d/2.0, y: @y/2.0 - @d/2.0),
        cylinder(d:@d).move(x: -@x/2.0 + @d/2.0, y: -@y/2.0 + @d/2.0),
        cylinder(d:@d).move(x: @x/2.0 - @d/2.0, y: -@y/2.0 + @d/2.0),
      )
      res
    end

  end
end
