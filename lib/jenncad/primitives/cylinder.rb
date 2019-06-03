module JennCad::Primitives
  class Cylinder < Primitive
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

      args[:z] ||= args[:h]

      @opts = {
        d: 0,
        z: nil,
        r: 0,
        margins: {
          r: 0,
          d: 0,
          z: 0,
        },
      }.deep_merge!(args)

      # FIXME:
      # - margins calculation needs to go to output
      # - assinging these variables has to stop
      # - r/d need to be automatically calculated by each other
      # - r+z margin not implemented atm
      # - need to migrate classes to provide all possible outputs (and non-conflicting ones) to openscad exporter
      @d = args[:d] + @opts[:margins][:d]
      @z = args[:z] || args[:h]
      @r = args[:r]
      @fn = args[:fn]
      super(args)
    end

    def h
      z
    end

  end
end
