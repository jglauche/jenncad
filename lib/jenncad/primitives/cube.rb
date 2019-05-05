module JennCad::Primitives
	class Cube < Primitive
		attr_accessor :x,:y,:z

		def initialize(args)
			super(args)
			if args.kind_of? Array
				size = args
			elsif args.kind_of? Hash
				size = args[:size]
			end
			if size
				@x,@y,@z = size.map{|l| l.to_f}
			end
			@h = @z.dup
			@calc_h = @z.dup
		end

		# used for openscad export
		def size
			[@x, @y, @z]
		end

		def center_xy
			@transformations << Move.new({x:-@x/2,y:-@y/2})
			self
		end

		def center_x
			@transformations << Move.new({x:-@x/2})
			self
		end

		def center_y
			@transformations << Move.new({y:-@y/2})
			self
		end

		def center_z
			@transformations << Move.new({z:-@z/2})
			self
		end

#		 def center
#			 @transformations << Move.new({x:-@x/2,y:-@y/2,z:-@z/2})
#			 self
#		 end

	end
end
