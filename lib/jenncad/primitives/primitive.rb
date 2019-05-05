module JennCad::Primitives
	class Primitive < JennCad::Thing
		attr_accessor :children, :transformations, :name
    attr_accessor :calc_x, :calc_y, :calc_z, :calc_h

		def initialize(args)
			@transformations = []
		  @name = args[:name] || ""
		  # calculated origin; only works for move atm
		  @calc_x = 0
		  @calc_y = 0
		  @calc_z = 0
      @calc_h = args[:h] || 0
		end

		def rotate(args)
			@transformations ||= []
			@transformations << Rotate.new(args)
			self
		end

		def rotate_around(point,args)
			x,y,z= point.x, point.y, point.z
			self.move(x:-x,y:-y,z:-z).rotate(args).move(x:x,y:y,z:z)
		end

		def move(args)
			@transformations ||= []
			@transformations << Move.new(args)
	    @calc_x += args[:x].to_f
      @calc_y += args[:y].to_f
      @calc_z += args[:z].to_f
			self
		end
    alias :translate :move

		def union(args)
			@transformations ||= []
			@transformations << Union.new(args)
			self
		end

		def mirror(args)
			@transformations ||= []
			@transformations << Mirror.new(args)
			self
		end

		def scale(args)
			if args.kind_of? Numeric or args.kind_of? Array
					args = {v:args}
			end
			@transformations ||= []
			@transformations << Scale.new(args)
			self
		end

		# copies the transformation of obj to self
		def transform(obj)
			@transformations ||= []
			@transformations += obj.transformations
			self
		end

    def color(args)
      @transformations ||= []
      @transformations << Color.new(args)
      self
    end

    def multmatrix(args)
      @transformations ||= []
      @transformations << Multmatrix.new(args)
      self
    end

    def skew(args)
      xy = args[:xy] || 0
      x = args[:x] || 0
      yx = args[:yx] || 0
      y = args[:y] || 0
      zx = args[:zx] || 0
      zy = args[:zy] || 0

      multmatrix([
        [1, xy, x, 0],
        [yx, 1, y, 0],
        [zx, zy, 1, 0],
        [0, 0, 0, 1]
      ])
    end

  end
end
