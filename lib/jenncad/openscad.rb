module JennCad

	class OpenScad
		def initialize(part, fn=64)
			@imports = []
			@modules = {}
			@main = root(part, "$fn=#{fn};")

			@export = ""
			@imports.uniq.each do |val|
				@export += "use <#{val}.scad>\n"
			end
			@modules.each do |key, val|
				@export += val
			end
			@export += @main
			puts "-----"
			puts @export
		end

		def save(file)
			File.open(file,"w") do |f|
				f.puts @export
			end
		end

		def root(part, head="")
			res = head
			res += handle_color(part)
			if part.transformations
				part.transformations.reverse.each do |trans|
					res += transformation(trans)
				end
			end
			res += parse(part)
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
			when JennCad::OpenScadImport
				handle_import(part)
			when JennCad::Aggregation
				handle_aggregation(part)
			when JennCad::UnionObject
				cmd('union', nil, part.parts)
			when JennCad::SubtractObject
				part.analyze_z_fighting
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
				if part.respond_to?(:parts) && part.parts != nil
				res = ""
				part.parts.each do |part|
						res += parse(part)
					end
				return res
				end
			end
		end

		def fmt_params(args)
			return "" if args == nil
			if args.kind_of? String
				return "\"#{args}\""
			elsif args.kind_of? Array
				return args.map do |l|
					if l == nil
						0
					elsif l.kind_of? Array
						l # skipping check of 2-dmin Arrays for now (used in multmatrix)
					elsif l.to_i == l.to_f
						l.to_i
					else
						l.to_f
					end
				end
			else
				res = []
				args.each do |k,v|
					if k.to_s == "fn"
						k = "$fn"
					end
					if v == nil
						next
					end
					if !v.kind_of?(Array) && v == v.to_i
						v = v.to_i
					end
					res << "#{k}=#{v}"
				end
				res.join(",")
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
				res << handle_color(item)
				res << parse(item)
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

	def handle_import(part)
		@imports << part.import
		return "#{part.name}(#{fmt_params(part.args)});"
	end

	def handle_aggregation(part)
		register_module(part) unless @modules[part.name]
		use_module(part.name)
	end

	# check children for color values
		# if none of the children has a color value, we can apply color to this object and all children
	# if any of the children (excluding children of the kind of BooleanObject) has a color value (that is different from ours), we will apply a fallback color to all children that do not have a color value themselves.

	def handle_color(part)
		if part && part.respond_to?(:color) && part.color
			if part.respond_to?(:parts)
				res = []
				if part.children_list.map{|l| l.color != nil && l.color != part.color}.include?(true)
					part.children_list.each do |child|
						if child.color == nil && child.color != part.color && !child.kind_of?(BooleanObject)
							child.fallback_color = part.color
						end
					end
					return ""
				end
			end
		end
		return apply_color(part)
	end

	def apply_color(part)
		if part && part.respond_to?(:color_or_fallback)
			color = part.color_or_fallback
			return "" if color == nil
			# Allowing color to be string, OpenScad compatible RGBA values of 0..1 or RGBA values of 0..255
			if color.kind_of?(Array) && color.map{|l| l.to_f > 1.0 ? true : false}.include?(true)
				color = color.map{|l| l.to_f/255.0}
			end
			return cmd_call("color", color)
		end
		return ""
	end

	def register_module(part)
		# can only accept aggregation
		@modules[part.name] = "module #{part.name}(){"
		@modules[part.name] += root(part.part)
		@modules[part.name] += "}"
	end

	def use_module(name)
		return cmd_call(name, nil).to_s+";"
	end

	def cmd_call(name, args)
		args = fmt_params(args)
		return "#{name}(#{args})"
	end

	def collect_params(part)
		res = {}
		[:d,:r,:h, :r1, :r2, :d1, :d2, :size, :m, :fn].each do |var|
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
		when JennCad::Mirror
			cmd_call("mirror",trans.coordinates)
		when JennCad::Multmatrix
			cmd_call("multmatrix",trans.m)
		else
			puts "[openscad exporter] Unkown transformation #{trans.class}"
			""
		end
	end

end
