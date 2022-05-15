module JennCad::Primitives
  class Primitive < JennCad::Thing
    attr_accessor :dimensions

    def initialize(*args)
      super(*args)
    end

    def handle_margins
      @x = @opts[:x].to_d + @opts[:margins][:x].to_d
      @y = @opts[:y].to_d + @opts[:margins][:y].to_d
      if @opts[:z]
        @z = @opts[:z].to_d + @opts[:margins][:z].to_d
      end
    end

    def handle_diameter
      @d = opts[:d].to_d
      @r = opts[:r].to_d
      if @d
        @r = @d/2.0
      elsif @r
        @d = @r*2
      end
    end

    def feed_opts(args)
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


  end
end
