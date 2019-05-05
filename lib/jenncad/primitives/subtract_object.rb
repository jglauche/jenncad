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
          res << get_primitives(part)
        end
      elsif obj.respond_to? :parts
        if obj.parts != nil
          obj.parts.each do |part|
            res << get_primitives(part) unless part.kind_of? SubtractObject
          end
        end
      else
        res << obj
      end
      res
    end

    def get_heights(obj)
      res = []
      obj.each do |part|
        if part.respond_to? :h
          res << part.h
        end
      end
      res
    end

    def analyze_z_fighting
      first = get_primitives(@parts.first).flatten
      others = get_primitives(@parts[1..-1]).flatten

      first_h = get_heights(first).uniq
      puts first_h.inspect
      if first_h.size > 1
        #puts "first heights mismatch: #{first_h.inspect}"
        return
      end
      compare_to = first_h.first
      others.each do |part|
        if part.respond_to? :h
          if part.h == compare_to
            puts "fixing possible z fighting: #{part.class} #{part.h}"
            part.h+=0.008
            part.translate(z:-0.004)
          end
        end
      end

    end

  end
end
