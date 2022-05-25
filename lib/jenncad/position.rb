module JennCad
  class Size
    attr_accessor :size
    def initialize(args={})
      @size = {
        x: args[:x].to_d,
        y: args[:y].to_d,
        z: args[:z].to_d,
        d: args[:d].to_d,
      }
    end

    def add(other)
      @size[:x] = [@size[:x], other.x].max
      @size[:y] = [@size[:y], other.y].max
      @size[:z] = [@size[:z], other.z].max
      @size[:d] = [@size[:d], other.d].max
      self
    end

    def x
      @size[:x]
    end

    def y
      @size[:y]
    end

    def z
      @size[:z]
    end

    def d
      @size[:d]
    end

  end

  class Point
    attr_accessor :pos
    def initialize(args={})
      @pos = {x: 0.to_d, y: 0.to_d, z: 0.to_d}
      add(args)
    end

    def x
      @pos[:x]
    end

    def y
      @pos[:y]
    end

    def z
      @pos[:z]
    end

    def zero?
      return true if x == 0.0 && y == 0.0 && z == 0.0
      false
    end

    def to_a
      if @z != 0.0
        [@pos[:x], @pos[:y], @pos[:z]]
      else
        [@pos[:x], @pos[:y]]
      end
    end

    def to_h
      @pos.clone.delete_if{|k,v| v.to_d == 0.0}
    end

    def add(args)
      if args.kind_of? Point
        @x += args.x
        @y += args.y
        @z += args.z
        return self
      end
      args.each do |k, val|
        if [:chain, :debug].include? k
          next
        end
        unless val.kind_of? Numeric
          next
        end
        if val.to_d == 0.0
          next
        end

        keys = k.to_s.chars
        axis = []
        axis << keys.delete("x")
        axis << keys.delete("y")
        axis << keys.delete("z")
        multi = 1

        if keys.size > 0
          if keys.include?("h")
            multi = 0.5
          elsif keys.include?("q")
            multi = 0.25
          elsif keys.include?("d")
            multi = 2.0
          end
          if keys.include?("n") || keys.include?("i")
            multi *= -1
          end
        end
        axis.compact.each do |a|
          @pos[a.to_sym] += val.to_d * multi.to_d
        end
      end

    end
  end

end
