class Array
	#	Assembles things on top of each other
	def assemble(partlib=nil, skip_z=false, z=0)
		map do |part|
			case part
			when Array
				res = part.assemble(partlib, true)
			when String, Symbol
				res = partlib[part].yield
			when Proc
				res = part.yield
			else
				res = part
			end
			# FIXME: I added 0.01 to all for now to fix z-fighting issues; this should not be hardcoded like this
			res, z = res.move(z:z), z + res.z.to_f + 0.01 unless skip_z
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
