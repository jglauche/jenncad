class Array
	#	Assembles things on top of each other
	def assemble(partlib=nil, z=0)
		map do |part|
			case part
			when Array
				res = part.assemble(partlib, 0)
			when String, Symbol
				res = partlib[part].yield
			when Proc
				res = part.yield
			else
				res = part
			end
			res, z = res.move(z:z), z + res.z.to_f
			res
		end
		.union
	end

	def union(&block)
		if block
			UnionObject.new(block.yield)
		else
		 UnionObject.new(self)
		end
	end
end
