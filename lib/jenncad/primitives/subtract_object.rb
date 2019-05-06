module JennCad::Primitives
  class SubtractObject < BooleanObject
    def initialize(part1, part2)
      super(part1,part2)
    end

    def add(part)
      super(part)
    end

    def get_primitives(obj)
      res = []
      if obj.kind_of? Array
        obj.each do |part|
          res << part.children_list
        end
      else
				res << obj.children_list
			end
			res
    end

    def get_heights(obj)
      res = []
      obj.each do |part|
        if part.respond_to? :calc_h
          res << part.calc_h
        end
      end
      res
    end

    def get_z(obj)
      res = []
      obj.each do |part|
        if part.respond_to? :calc_z
          res << part.calc_z
        end
      end
      res
    end

    def analyze_z_fighting
      first = get_primitives(@parts.first).flatten
      others = get_primitives(@parts[1..-1]).flatten

			first_h = get_heights(first).uniq
      first_z = get_z(first).uniq
      puts first.inspect
      if first_h.size > 1
				puts "first item has multiple heights: #{first_h.inspect}"
      	first_h.each do |h|
					compare_z(others, h, first_z.first)
				end
			else
  			compare_z(others, first_h.first, first_z.first)
			end
		end

		# FIXME
		# this won't work reliable with Aggregations at the moment;
		# they don't have calc_z for comparing with the top
		# and it will try to move the Aggregation which it should not do
		# (it should move the calls to the Aggregation, not the Aggregation itself)
		def compare_z(others,compare_h,compare_z)
			others.each do |part|
				#puts part.inspect
				#puts "#{part.calc_z+part.calc_h} ; #{compare_h}"
				if part.respond_to? :h
          if part.h == compare_h
            puts "fixing possible z fighting: #{part.class} #{part.h}"
            part.h+=0.008
            part.translate(z:-0.004)
          elsif part.calc_z == compare_z
            puts "z fighting at bottom: #{part.calc_z}"
            part.h+=0.004
            part.translate(z:-0.002)
          elsif part.calc_z+part.calc_h == compare_h
            puts "z fighting at top: #{compare_h}"
            part.h+=0.004
            part.translate(z:0.002)
          end
        end
      end
    end

  end
end
