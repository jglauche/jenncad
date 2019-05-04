module JennCad

  class OpenScad
		def initialize(part)
			@duplicates = []
			a = print_tree(part)
			puts a.inspect
			puts "---"
			@duplicates = a.detect{ |e| a.count(e) > 1 }
			@modules = {}
			@head = ""
			@duplicates ||= []
			@duplicates.each_with_index do |m,i|
				next if m.kind_of? Array
				puts m
				@modules[m] = "m#{i}"
				@head += "module m#{i}(){"
				@head += m.to_s
				@head += "}"
			end
			puts @duplicates.inspect
			res = head(part)
			puts "-----"
			puts res
		end

		def head(part)
			res = @head
			part.transformations.reverse.each do |trans|
				res << transformation(trans)
			end
			res << parse(part)
		end

		def print_tree(part, level=0)
			arr = []
			arr << parse(part) unless level == 0
			if part.respond_to?(:parts)
				part.parts.each do |part|
					arr << print_tree(part,level+1)
				end
			end
			arr
		end


		def parse(part)
			case part
			when JennCad::UnionObject
				cmd('union', nil, part.parts)
			when JennCad::SubtractObject
				cmd('difference', nil, part.parts)
			when JennCad::IntersectionObject
				cmd('intersection', nil, part.parts)
			when JennCad::HullObject
				cmd('hull', nil, part.parts)
			when JennCad::Primitives::Cylinder
				cmd('cylinder', collect_params(part), nil)
			when JennCad::Primitives::Cube
				cmd('cube', collect_params(part), nil)
			else
				puts "[openscad exporter] Unknown class: #{part.class}"
			end
		end

		def fmt_params(args)
			return "" if args == nil
			if args.kind_of? Array
				return args.map{|l| l.to_f}
			else
				return args.map{|k,v| "#{k}=#{v}"}.join(",")
			end
		end

		def cmd(name, args, items)
			items ||= []

			res = cmd_call(name,args)
			if items.size > 1
				res << "{"
			end
			items.each do |item|
				if item.respond_to?(:transformations) && item.transformations != nil && item.transformations.size > 0
					item.transformations.reverse.each do |trans|
						res << transformation(trans)
					end
				end
				resp = parse(item)
				if resp != nil && @duplicates.include?(resp)
					res << use_module(resp)
				else
					res << resp
				end
			end
			if items.size > 1
				res << "}"
			end
			if items.size <= 1
				res << ";"
			end
			return res
		end
  end

	def use_module(resp)
		return cmd_call(@modules[resp], nil).to_s+";"
	end

	def cmd_call(name, args)
		args = fmt_params(args)
		return "#{name}(#{args})"
	end

	def collect_params(part)
		res = {}
		[:d,:r,:h, :r1, :r2, :d1, :d2, :size].each do |var|
			if part.respond_to? var
				res[var] = part.send var
			end
		end
		res
	end

	def transformation(trans)
		case trans
		when JennCad::Move
			cmd_call("translate",trans.coordinates)
		when JennCad::Rotate
			cmd_call("rotate",trans.coordinates)
		else
			puts "[openscad exporter] Unkown transformation #{trans.class}"
			""
		end
	end

end
