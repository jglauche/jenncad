module JennCad::Primitives
  class Circle < Primitive
    include CircleIsh

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

    def openscad_params
      res = {}
      [:d, :fn].each do |n|
        res[n] = self.send n
      end
      res
    end


  end
end
