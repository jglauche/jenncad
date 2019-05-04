module JennCad::Primitives
	class Primitive
		attr_accessor :children

		def initialize(*args)
			@transformations = []
		end

		def rotate(args)
		  # always make sure we have a z parameter; otherwise RubyScad will produce a 2-dimensional output
		  # which can result in openscad weirdness
		  if args[:z] == nil
		    args[:z] = 0
		  end
			@transformations ||= []
			@transformations << Rotate.new(args)
			self
		end

		def rotate_around(point,args)
			x,y,z= point.x, point.y, point.z
			self.translate(x:-x,y:-y,z:-z).rotate(args).translate(x:x,y:y,z:z)
		end

		def translate(args)
			@transformations ||= []
			@transformations << Translate.new(args)
			self
		end

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


  end
end
